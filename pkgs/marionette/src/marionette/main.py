import argparse
import datetime
from operator import itemgetter
from typing import Iterable, List, Dict
from decimal import Decimal
from . import ledger, monzo

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
  if monzo_tx.get("merchant") and monzo_tx["merchant"].get("name"):
    ledger_tx.summary = monzo_tx["merchant"]["name"]
  ledger_tx.monzo_ids = [monzo_tx["id"]]
  ledger_tx.timestamp = timestamp
  assert monzo_tx["currency"] == "GBP", monzo_tx
  amount = Decimal(monzo_tx["amount"]) / Decimal(100)
  if monzo_tx.get("metadata", {}).get("pot_id"):
    pot_name = monzo_pots[monzo_tx["metadata"]["pot_id"]]["name"]
    counter_account = ledger.Account(f"{ledger.accounts.MONZO}:{pot_name}")
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
  ], key=lambda p: -p.amount)
  return ledger_tx

def set_balance_assertion(lg: ledger.Ledger, monzo_txs: List[monzo.Transaction], balance: Decimal) -> None:
  monzo_tx = max(monzo_txs, key=itemgetter("created"))
  ledger_tx = lg.transactions_by_monzo_id()[monzo_tx["id"]]
  postings = [p for p in ledger_tx.postings if p.account == ledger.accounts.MONZO]
  if len(postings) != 1:
    raise Exception(f"{ledger_tx.date} {ledger_tx.summary}: not sure how to add balance assertion here")
  [posting] = postings
  posting.balance_assertion = balance

if __name__ == "__main__":
  main()
