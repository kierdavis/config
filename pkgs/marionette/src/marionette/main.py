import argparse
import datetime
from operator import itemgetter
from typing import Iterable, List, Dict
from decimal import Decimal
from . import ledger, monzo, errors, monzo_sync

def main() -> None:
  parser = argparse.ArgumentParser()
  subparsers = parser.add_subparsers(required=True)
  validate_parser = subparsers.add_parser("validate")
  validate_parser.set_defaults(cmd=cmd_validate)
  monzo_sync_parser = subparsers.add_parser("monzo-sync")
  monzo_sync_parser.set_defaults(cmd=cmd_monzo_sync)
  args = parser.parse_args()
  args.cmd(args)

def cmd_validate(args: argparse.Namespace) -> None:
  lg = ledger.Ledger.load()
  lg.save()

def cmd_monzo_sync(args: argparse.Namespace) -> None:
  lg = ledger.Ledger.load()
  monzo_sync.sync(lg)
  lg.save()

if __name__ == "__main__":
  main()
