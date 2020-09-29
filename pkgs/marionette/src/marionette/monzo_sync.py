from . import ledger, monzo, errors
import datetime
from decimal import Decimal
from operator import itemgetter, attrgetter
from typing import List, Dict

def sync(lg: ledger.Ledger) -> None:
  monzo_api = monzo.Monzo.login()
  monzo_balance = monzo_api.balance()
  monzo_txs = monzo_api.transactions()
  monzo_pots = {pot["id"]: pot for pot in monzo_api.pots()}
  create_missing_txs(lg, monzo_txs, monzo_pots)
  sync_txs(lg, monzo_txs)
  set_balance_assertion(lg, monzo_txs, monzo_balance)

def create_missing_txs(
  lg: ledger.Ledger,
  monzo_txs: List[monzo.Transaction],
  monzo_pots: Dict[monzo.PotId, monzo.Pot],
) -> None:
  existing_ledger_txs = lg.transactions_by_monzo_id()
  for monzo_tx in monzo_txs:
    if monzo_tx.get("decline_reason") or monzo_tx.get("amount") == 0:
      continue
    if monzo_tx["id"] not in existing_ledger_txs:
      lg.transactions.append(create_ledger_tx_from_monzo_tx(monzo_tx, monzo_pots, lg))

def create_ledger_tx_from_monzo_tx(monzo_tx: monzo.Transaction, monzo_pots: Dict[monzo.PotId, monzo.Pot], lg: ledger.Ledger) -> ledger.Transaction:
  ledger_tx = ledger.Transaction(
    date = datetime.date.today(), # will be later overriden by sync_tx
    summary = monzo_tx["description"],
  )
  ledger_tx.monzo_ids = frozenset({monzo_tx["id"]})
  merchant_name = monzo.TransactionUtil.merchant(monzo_tx).get("name", "")
  if merchant_name:
    ledger_tx.summary = merchant_name
  amount = monzo.TransactionUtil.amount(monzo_tx)
  if monzo_tx.get("metadata", {}).get("pot_id"):
    pot_name = monzo_pots[monzo_tx["metadata"]["pot_id"]]["name"]
    counter_account = ledger.Account(f"{ledger.accounts.MONZO_POT_BASE}:{pot_name}")
    if amount > 0:
      ledger_tx.summary = f"Withdrawal from {pot_name} pot"
    else:
      ledger_tx.summary = f"Deposit into {pot_name} pot"
  else:
    counter_account = get_counter_account(monzo_tx, lg)
  ledger_tx.postings = [
    ledger.Posting(ledger.accounts.MONZO, amount),
    ledger.Posting(counter_account, -amount),
  ]
  return ledger_tx

def get_counter_account(monzo_tx: monzo.Transaction, lg: ledger.Ledger) -> ledger.Account:
  merchant_id = monzo.TransactionUtil.merchant(monzo_tx).get("id", "")
  if merchant_id:
    similar_txs = (tx for tx in lg.transactions if tx.monzo_merchant_ids == {merchant_id})
    try:
      similar_tx = max(similar_txs, key=attrgetter("timestamp"))
    except ValueError:
      pass
    else:
      counter_account = similar_tx.counter_account
      if counter_account is not None:
        return counter_account
  if monzo.TransactionUtil.amount(monzo_tx) > 0:
    return ledger.accounts.INCOME
  else:
    return ledger.accounts.EXPENSES

def sync_txs(lg: ledger.Ledger, monzo_txs: List[monzo.Transaction]) -> None:
  monzo_txs_by_id = {mt["id"]: mt for mt in monzo_txs}
  for ledger_tx in lg.transactions:
    try:
      these_monzo_txs = [monzo_txs_by_id[i] for i in ledger_tx.monzo_ids]
    except KeyError:
      # We don't have access to one or more monzo transactions (90 day limit).
      continue
    sync_tx(ledger_tx, these_monzo_txs)

def sync_tx(ledger_tx: ledger.Transaction, monzo_txs: List[monzo.Transaction]) -> None:
  if not monzo_txs:
    return
  # Timestamp
  timestamp = min(monzo.TransactionUtil.timestamp(monzo_tx) for monzo_tx in monzo_txs)
  ledger_tx.date = timestamp.date()
  ledger_tx.timestamp = timestamp
  # Validate amount
  ledger_amount = ledger_tx.amounts.get(ledger.accounts.MONZO, Decimal(0))
  monzo_amount = sum((monzo.TransactionUtil.amount(mt) for mt in monzo_txs), Decimal(0))
  if ledger_amount != monzo_amount:
    raise errors.LedgerAmountDoesNotMatchMonzo(
      ledger_tx = ledger_tx,
      monzo_txs = monzo_txs,
      account = ledger.accounts.MONZO,
      ledger_amount = ledger_amount,
      monzo_amount = monzo_amount,
    )
  # Metadata
  ledger_tx.monzo_merchant_ids = frozenset({monzo.TransactionUtil.merchant(mt).get("id", monzo.MerchantId("")) for mt in monzo_txs} - {monzo.MerchantId("")})
  
def set_balance_assertion(lg: ledger.Ledger, monzo_txs: List[monzo.Transaction], balance: Decimal) -> None:
  monzo_tx = max(monzo_txs, key=itemgetter("created"))
  ledger_tx = lg.transactions_by_monzo_id()[monzo_tx["id"]]
  postings = [p for p in ledger_tx.postings if p.account == ledger.accounts.MONZO]
  if len(postings) != 1:
    # not sure how to add balance assertion here
    return
  [posting] = postings
  posting.balance_assertion = balance
