import datetime
from pathlib import Path
from dataclasses import dataclass, field
from typing import NewType, Dict, Optional, List, cast, FrozenSet
from decimal import Decimal
from operator import attrgetter
from . import monzo, errors
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
class RecurringInfo:
  frequency: str = "monthly"
  
@dataclass
class Posting:
  account: Account
  amount: Optional[Amount]
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
  def monzo_ids(self) -> FrozenSet[monzo.TransactionId]:
    s = self.metadata.get("MonzoIds", "")
    if not s:
      return frozenset()
    return frozenset(monzo.TransactionId(i) for i in s.split())

  @monzo_ids.setter
  def monzo_ids(self, ids: FrozenSet[monzo.TransactionId]) -> None:
    if ids:
      self.metadata["MonzoIds"] = " ".join(sorted(ids))
    else:
      self.metadata.pop("MonzoIds", "")

  @property
  def monzo_merchant_ids(self) -> FrozenSet[monzo.MerchantId]:
    s = self.metadata.get("MonzoMerchantIds", "")
    if not s:
      return frozenset()
    return frozenset(monzo.MerchantId(i) for i in s.split())

  @monzo_merchant_ids.setter
  def monzo_merchant_ids(self, ids: FrozenSet[monzo.MerchantId]) -> None:
    if ids:
      self.metadata["MonzoMerchantIds"] = " ".join(sorted(ids))
    else:
      self.metadata.pop("MonzoMerchantIds", "")

  @property
  def timestamp(self) -> datetime.datetime:
    s = self.metadata.get("Timestamp", "")
    if not s:
      return datetime.datetime.combine(self.date, datetime.time(), tzinfo=datetime.timezone.utc)
    return datetime.datetime.strptime(s, TIMESTAMP_FORMAT)

  @timestamp.setter
  def timestamp(self, ts: datetime.datetime) -> None:
    self.metadata["Timestamp"] = ts.strftime(TIMESTAMP_FORMAT)

  @property
  def recurring(self) -> Optional[RecurringInfo]:
    s = self.metadata.get("Recurring", "")
    if not s:
      return None
    info = RecurringInfo()
    for word in s.split():
      if word in ["monthly"]:
        info.frequency = word
      else:
        raise ValueError(word)
    return info

  @property
  def is_prediction(self) -> bool:
    return bool(self.metadata.get("IsPrediction", ""))

  @is_prediction.setter
  def is_prediction(self, val: bool) -> None:
    if val:
      self.metadata["IsPrediction"] = "true"
    elif "IsPrediction" in self.metadata:
      del self.metadata["IsPrediction"]

  @property
  def amounts(self) -> Dict[Account, Amount]:
    amounts: Dict[Account, Amount] = {}
    elided_postings = []
    for p in self.postings:
      if p.amount is not None:
        amounts[p.account] = amounts.get(p.account, Decimal(0)) + p.amount
      else:
        elided_postings.append(p)
    if len(elided_postings) > 1:
      raise errors.PostingElisionError(tx=self)
    elif elided_postings:
      [elided_posting] = elided_postings
      elided_posting.amount = elided_amount = -sum(amounts.values(), Decimal(0))
      amounts[elided_posting.account] = amounts.get(elided_posting.account, Decimal(0)) + elided_amount
    return amounts

  def validate(self) -> None:
    amount_sum = sum(self.amounts.values(), Decimal(0))
    if amount_sum != Decimal(0):
      raise errors.UnbalancedTransactionError(tx=self, actual_sum=amount_sum)

  @property
  def short_str(self) -> str:
    date = self.date.strftime("%Y-%m-%d")
    return f"{date} {self.summary}" 

  def __str__(self) -> str:
    s = f"{self.short_str}\n"
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
    self._ensure_all_accounts_are_leaves()
    self._create_predictions()
    for tx in self.transactions:
      tx.validate()

  def _ensure_all_accounts_are_leaves(self) -> None:
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

  def _create_predictions(self) -> None:
    return

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
