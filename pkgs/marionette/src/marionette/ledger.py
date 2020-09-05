import datetime
from pathlib import Path
from dataclasses import dataclass, field
from typing import NewType, Dict, Optional, List, cast
from decimal import Decimal
from operator import attrgetter
from . import monzo
from .util import append_right_aligned

LEDGER_PATH = Path.home() / ".marionette" / "ledger"

TIMESTAMP_FORMAT = "%Y-%m-%dT%H:%M:%S%z"

Account = NewType("Account", str)
Amount = Decimal

class accounts:
  MONZO = Account("Assets:Monzo:Main")
  MONZO_POT_BASE = Account("Assets:Monzo")
  INCOME = Account("Income")
  EXPENSES = Account("Expenses")

@dataclass
class Posting:
  account: Account
  amount: Amount
  balance_assertion: Optional[Amount] = None
  metadata: Dict[str, str] = field(default_factory=dict)

  def __str__(self) -> str:
    s = f"  {self.account}"
    s = append_right_aligned(s, f"£{self.amount:.2f}", 50, min_spaces=2)
    if self.balance_assertion is not None:
      s = append_right_aligned(s, f"= £{self.balance_assertion:.2f}", 70, min_spaces=1)
    s += "\n"
    for key, value in self.metadata.items():
      s += f"    ; {key}: {value}\n"
    return s

@dataclass
class Transaction:
  date: datetime.date
  summary: str
  metadata: Dict[str, str] = field(default_factory=dict)
  postings: List[Posting] = field(default_factory=list)

  @property
  def monzo_ids(self) -> List[monzo.TransactionId]:
    s = self.metadata.get("MonzoIds", "")
    if not s:
      return []
    return [monzo.TransactionId(i) for i in s.split()]

  @monzo_ids.setter
  def monzo_ids(self, ids: List[monzo.TransactionId]) -> None:
    self.metadata["MonzoIds"] = " ".join(ids)

  @property
  def timestamp(self) -> datetime.datetime:
    s = self.metadata.get("Timestamp", "")
    if not s:
      return datetime.datetime.combine(self.date, datetime.time(), tzinfo=datetime.timezone.utc)
    return datetime.datetime.strptime(s, TIMESTAMP_FORMAT)

  @timestamp.setter
  def timestamp(self, ts: datetime.datetime) -> None:
    self.metadata["Timestamp"] = ts.strftime(TIMESTAMP_FORMAT)

  def validate(self) -> None:
    if sum(p.amount for p in self.postings) != 0:
      raise ValueError(f"{self.date} {self.summary}: posting amounts do not sum to zero")

  def __str__(self) -> str:
    date = self.date.strftime("%Y-%m-%d")
    s = f"{date} {self.summary}\n"
    for key, value in sorted(self.metadata.items()):
      s += f"  ; {key}: {value}\n"
    for posting in self.postings:
      s += str(posting)
    return s

@dataclass
class Ledger:
  transactions: List[Transaction] = field(default_factory=list)

  def transactions_by_monzo_id(self) -> Dict[monzo.TransactionId, Transaction]:
    return {id: tx for tx in self.transactions for id in tx.monzo_ids}

  def validate(self) -> None:
    self._validate_account_tree()
    for tx in self.transactions:
      tx.validate()

  def _validate_account_tree(self) -> None:
    accounts = {p.account for tx in self.transactions for p in tx.postings}
    accounts_with_children = set()
    for acc in accounts:
      while ":" in acc:
        acc_str, _ = acc.rsplit(":", 1)
        acc = Account(acc_str)
        accounts_with_children.add(acc)
    for tx in self.transactions:
      for p in tx.postings:
        if p.account in accounts_with_children:
          p.account = Account(f"{p.account}:Misc")

  def __str__(self) -> str:
    txs = sorted(self.transactions, key=attrgetter("timestamp"))
    return "\n".join(map(str, txs))

  @classmethod
  def load(cls) -> "Ledger":
    from . import ledger_parser  # avoid circular import
    if LEDGER_PATH.exists():
      return ledger_parser.parse_string(LEDGER_PATH.read_text())  # type: ignore
    else:
      return cls()

  def save(self) -> None:
    self.validate()
    LEDGER_PATH.write_text(str(self))
