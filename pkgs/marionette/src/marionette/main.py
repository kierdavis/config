import argparse
import datetime
from operator import itemgetter
from typing import Iterable, List, Dict
from decimal import Decimal
from . import ledger, monzo, errors

def main() -> None:
  parser = argparse.ArgumentParser()
  subparsers = parser.add_subparsers(required=True)
  validate_parser = subparsers.add_parser("validate")
  validate_parser.set_defaults(cmd=cmd_validate)
  monzo_import_parser = subparsers.add_parser("monzo-import")
  monzo_import_parser.set_defaults(cmd=cmd_monzo_import)
  args = parser.parse_args()
  args.cmd(args)

def cmd_validate(args: argparse.Namespace) -> None:
  lg = ledger.Ledger.load()
  lg.save()

def cmd_monzo_import(args: argparse.Namespace) -> None:
  lg = ledger.Ledger.load()
  monzo_api = monzo.Monzo.login()
  monzo_balance = monzo_api.balance()
  monzo_txs = monzo_api.transactions()
  monzo_pots = {pot["id"]: pot for pot in monzo_api.pots()}
  create_missing_ledger_txs_from_monzo_txs(lg, monzo_txs, monzo_pots)
  update_ledger_txs_from_monzo_txs(lg, monzo_txs)
  set_balance_assertion(lg, monzo_txs, monzo_balance)
  lg.save()

def create_missing_ledger_txs_from_monzo_txs(
  lg: ledger.Ledger,
  monzo_txs: List[monzo.Transaction],
  monzo_pots: Dict[monzo.PotId, monzo.Pot],
) -> None:
  existing_ledger_txs = lg.transactions_by_monzo_id()
  for monzo_tx in monzo_txs:
    if monzo_tx.get("decline_reason") or monzo_tx.get("amount") == 0:
      continue
    if monzo_tx["id"] not in existing_ledger_txs:
      lg.transactions.append(create_ledger_tx_from_monzo_tx(monzo_tx, monzo_pots))

def create_ledger_tx_from_monzo_tx(monzo_tx: monzo.Transaction, monzo_pots: Dict[monzo.PotId, monzo.Pot]) -> ledger.Transaction:
  timestamp = datetime.datetime.strptime(monzo_tx["created"], "%Y-%m-%dT%H:%M:%S.%f%z")
  ledger_tx = ledger.Transaction(
    date = timestamp.date(),
    summary = monzo_tx["description"],
  )
  merchant_name = monzo.TransactionUtil.merchant(monzo_tx).get("name", "")
  if merchant_name:
    ledger_tx.summary = merchant_name
  ledger_tx.monzo_ids = frozenset({monzo_tx["id"]})
  amount = monzo.TransactionUtil.amount(monzo_tx)
  if monzo_tx.get("metadata", {}).get("pot_id"):
    pot_name = monzo_pots[monzo_tx["metadata"]["pot_id"]]["name"]
    counter_account = ledger.Account(f"{ledger.accounts.MONZO_POT_BASE}:{pot_name}")
    if amount > 0:  # pot -> account
      ledger_tx.summary = f"Withdrawal from {pot_name} pot"
    else:
      ledger_tx.summary = f"Deposit into {pot_name} pot"
  elif amount > 0:
    counter_account = ledger.accounts.INCOME
  else:
    counter_account = ledger.accounts.EXPENSES
  # Sort postings such that destination comes first.
  ledger_tx.postings = sorted([
    ledger.Posting(ledger.accounts.MONZO, amount),
    ledger.Posting(counter_account, -amount),
  ], key=lambda p: -(p.amount or 0))
  return ledger_tx

def update_ledger_txs_from_monzo_txs(lg: ledger.Ledger, monzo_txs: List[monzo.Transaction]) -> None:
  monzo_txs_by_id = {mt["id"]: mt for mt in monzo_txs}
  for ledger_tx in lg.transactions:
    try:
      these_monzo_txs = [monzo_txs_by_id[i] for i in ledger_tx.monzo_ids]
    except KeyError:
      # We don't have access to one or more monzo transactions (90 day limit).
      continue
    update_ledger_tx_from_monzo_txs(ledger_tx, these_monzo_txs)

def update_ledger_tx_from_monzo_txs(ledger_tx: ledger.Transaction, monzo_txs: List[monzo.Transaction]) -> None:
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

if __name__ == "__main__":
  main()
