import datetime
import warnings
import uuid
import dataclasses
from pathlib import Path
from dataclasses import dataclass, field
from typing import NewType, Dict, Optional, List, cast, FrozenSet, Set
from decimal import Decimal
from operator import attrgetter
from . import monzo, errors
from .util import append_right_aligned
from typing_extensions import Protocol

LEDGER_PATH = Path.home() / ".marionette" / "ledger"

TIMESTAMP_FORMAT = "%Y-%m-%dT%H:%M:%S%z"

Account = NewType("Account", str)
Amount = Decimal

class accounts:
  MONZO = Account("Assets:Monzo:Main")
  MONZO_POT_BASE = Account("Assets:Monzo")
  INCOME = Account("Income")
  EXPENSES = Account("Expenses")

class PredictionResolutionCriteria(Protocol):
  def matches(self, prediction: "Transaction", concrete: "Transaction") -> bool: ...

@dataclass
class MerchantEquals(PredictionResolutionCriteria):
  merchant_id: monzo.MerchantId
  def matches(self, prediction: "Transaction", concrete: "Transaction") -> bool:
    return self.merchant_id in concrete.monzo_merchant_ids

@dataclass
class DateWithin(PredictionResolutionCriteria):
  max_days: int
  def matches(self, prediction: "Transaction", concrete: "Transaction") -> bool:
    return abs((prediction.date - concrete.date).days) <= self.max_days

@dataclass
class AmountWithin(PredictionResolutionCriteria):
  max_delta: Decimal
  def matches(self, prediction: "Transaction", concrete: "Transaction") -> bool:
    [p_amount, c_amount] = [
      sum((amount for account, amount in tx.amounts.items() if account == accounts.MONZO or account.startswith(accounts.MONZO_POT_BASE + ":")), Decimal(0))
      for tx in [prediction, concrete]
    ]
    return abs(p_amount - c_amount) <= self.max_delta

@dataclass
class PredictionSpec:
  frequency: str = "monthly"
  criteria: List[PredictionResolutionCriteria] = field(default_factory=list)

  @classmethod
  def parse(cls, s: str, tx: "Transaction") -> "PredictionSpec":
    spec = cls()
    for word in s.split():
      if word in {"monthly", "yearly"}:
        spec.frequency = word
      elif word.startswith("merchant_id="):
        merchant_id = monzo.MerchantId(word.split("=")[1])
        spec.criteria.append(MerchantEquals(merchant_id))
      elif word.startswith("date_within="):
        max_days = int(word.split("=", 1)[1].strip("d"))
        spec.criteria.append(DateWithin(max_days))
      elif word.startswith("amount_within="):
        max_delta = Decimal(word.split("=", 1)[1].strip("£"))
        spec.criteria.append(AmountWithin(max_delta))
      else:
        raise errors.InvalidPredictionSpecError(tx=tx, input=s)
    if not spec.criteria:
      raise errors.InvalidPredictionSpecError(tx=tx, input=s)
    return spec

  def predict_next_transaction(self, ref_tx: "Transaction") -> "Transaction":
    tx = dataclasses.replace(ref_tx,
      date = self.predict_next_date(ref_tx.date),
      postings = [
        dataclasses.replace(ref_post,
          balance_assertion=None,
        )
        for ref_post in ref_tx.postings
      ],
      metadata = {k: v for k, v in ref_tx.metadata.items() if k not in {"MonzoIds", "MonzoMerchantIds", "Timestamp", "PredictionState"}},
    )
    return tx

  def predict_next_date(self, ref_date: datetime.date) -> datetime.date:
    if self.frequency == "monthly":
      year, month, day = ref_date.year, ref_date.month+1, ref_date.day
      if month > 12:
        year, month = year+1, month-12
      day = min(day, [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month-1])
      return datetime.date(year, month, day)
    elif self.frequency == "yearly":
      return datetime.date(ref_date.year+1, ref_date.month, ref_date.day)
    else:
      raise ValueError(self.frequency)

  def matches(self, prediction: "Transaction", concrete: "Transaction") -> bool:
    return all(criterion.matches(prediction, concrete) for criterion in self.criteria)

PredictionLink = NewType("PredictionLink", str)

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
  def prediction_spec(self) -> Optional[PredictionSpec]:
    s = self.metadata.get("Predict", "")
    if not s:
      return None
    return PredictionSpec.parse(s, self)

  @property
  def prediction_link(self) -> Optional[PredictionLink]:
    s = self.metadata.get("PredictionLink", "")
    if not s:
      return None
    return PredictionLink(s)

  @prediction_link.setter
  def prediction_link(self, val: Optional[PredictionLink]) -> None:
    if val is not None:
      self.metadata["PredictionLink"] = val
    else:
      self.metadata.pop("PredictionLink", "")

  @property
  def is_prediction(self) -> bool:
    return bool(self.metadata.get("IsPrediction", ""))

  @is_prediction.setter
  def is_prediction(self, val: bool) -> None:
    if val:
      self.metadata["IsPrediction"] = "true"
    else:
      self.metadata.pop("IsPrediction", "")

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
    self._manage_predictions()
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

  def _manage_predictions(self) -> None:
    now = max(tx.timestamp for tx in self.transactions if not tx.is_prediction)
    self._resolve_predictions(now)
    self._prune_dead_prediction_links()
    self._create_new_predictions(now)

  def _resolve_predictions(self, now: datetime.datetime) -> None:
    txs_to_remove = []
    for predicted_tx in self.transactions:
      spec = predicted_tx.prediction_spec
      if spec is None or not predicted_tx.is_prediction:
        continue
      matching_txs = [other_tx for other_tx in self.transactions if not other_tx.is_prediction and spec.matches(predicted_tx, other_tx)]
      if len(matching_txs) > 1:
        raise errors.MultipleTransactionsMatchPredictionError(prediction=predicted_tx, matches=matching_txs)
      if len(matching_txs) < 1:
        if predicted_tx.date < now.date():
          warnings.warn(errors.PredictionResolutionWarning(prediction=predicted_tx))
        continue
      [matching_tx] = matching_txs
      matching_tx.metadata["Predict"] = predicted_tx.metadata["Predict"]
      txs_to_remove.append(predicted_tx)
    for tx in txs_to_remove:
      self.transactions.remove(tx)

  def _prune_dead_prediction_links(self) -> None:
    txs_by_link: Dict[PredictionLink, List[Transaction]] = {}
    for tx in self.transactions:
      link = tx.prediction_link
      if link is not None:
        txs_by_link.setdefault(link, []).append(tx)
    for link, txs in txs_by_link.items():
      if len(txs) < 2:
        for tx in txs:
          tx.prediction_link = None
      elif len(txs) > 2:
        raise errors.OverusedPredictionLinkError(link=link, txs=txs)

  def _create_new_predictions(self, now: datetime.datetime) -> None:
    txs_to_add = []
    for tx in self.transactions:
      spec = tx.prediction_spec
      if spec is None or tx.prediction_link is not None:
        continue
      predicted_tx = spec.predict_next_transaction(tx)
      if predicted_tx.date < now.date():
        continue
      link = PredictionLink(uuid.uuid4().hex)
      tx.prediction_link = link
      predicted_tx.prediction_link = link
      predicted_tx.is_prediction = True
      txs_to_add.append(predicted_tx)
    self.transactions += txs_to_add

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
