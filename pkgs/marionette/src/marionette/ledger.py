import datetime
import warnings
import uuid
import dataclasses
from enum import Enum, auto
from pathlib import Path
from dataclasses import dataclass, field
from typing import NewType, Dict, Optional, List, cast, FrozenSet, Set, Tuple
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

class PredictionState(Enum):
  REFERENCE = auto()
  PREDICTION = auto()
  SUPERSEDED = auto()

@dataclass
class PredictionData:
  state: PredictionState
  link: PredictionLink

  @classmethod
  def parse(cls, s: str) -> "PredictionData":
    state_str, link_str = s.split()
    return cls(PredictionState[state_str.upper()], PredictionLink(link_str))

  def __str__(self) -> str:
    return f"{self.state.name.lower()} {self.link}"

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

  @staticmethod
  def sort_key(post: "Posting") -> Tuple[int, str]:
    major: int
    if post.amount is None:
      major = 2
    elif post.amount < 0:
      major = 1
    else:
      major = 0
    return major, post.account

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
      return datetime.datetime.combine(self.date, datetime.time(23, 59, 59), tzinfo=datetime.timezone.utc)
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
  def prediction_data(self) -> Optional[PredictionData]:
    s = self.metadata.get("PredictionData", "")
    if not s:
      return None
    return PredictionData.parse(s)

  @prediction_data.setter
  def prediction_data(self, val: Optional[PredictionData]) -> None:
    if val is not None:
      self.metadata["PredictionData"] = str(val)
    else:
      self.metadata.pop("PredictionData", "")

  @property
  def is_prediction(self) -> bool:
    if bool(self.metadata.get("IsPrediction", "")):
      return True
    data = self.prediction_data
    return data is not None and data.state == PredictionState.PREDICTION

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

  @property
  def counter_account(self) -> Optional[Account]:
    candidates = {p.account for p in self.postings if not (p.account == accounts.MONZO or p.account.startswith(accounts.MONZO_POT_BASE+":"))}
    if len(candidates) == 1:
      return list(candidates)[0]
    else:
      return None

  def validate(self) -> None:
    amount_sum = sum(self.amounts.values(), Decimal(0))
    if amount_sum != Decimal(0):
      raise errors.UnbalancedTransactionError(tx=self, actual_sum=amount_sum)

  @property
  def short_str(self) -> str:
    cleared_marker = "" if self.is_prediction else " *"
    date = self.date.strftime("%Y-%m-%d")
    return f"{date}{cleared_marker} {self.summary}"

  def __str__(self) -> str:
    s = f"{self.short_str}\n"
    for key, value in sorted(self.metadata.items()):
      s += f"  ; {key}: {value}\n"
    for posting in sorted(self.postings, key=Posting.sort_key):
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
    today = max(tx.timestamp for tx in self.transactions if not tx.is_prediction).date()
    txs_by_link: Dict[PredictionLink, List[Transaction]] = {}
    for tx in self.transactions:
      spec, maybe_data = tx.prediction_spec, tx.prediction_data
      if spec is None:
        continue
      data: PredictionData
      if maybe_data is not None:
        data = maybe_data
      else:
        data = PredictionData(PredictionState.REFERENCE, PredictionLink(uuid.uuid4().hex))
        tx.prediction_data = data
      if data.state != PredictionState.SUPERSEDED:
        txs_by_link.setdefault(data.link, []).append(tx)
    for link, txs in txs_by_link.items():
      changed = True
      while changed:
        changed = False
        reference_tx = self._get_reference(txs, link)
        spec = reference_tx.prediction_spec
        assert spec is not None
        maybe_prediction_tx = self._get_prediction(txs)
        if maybe_prediction_tx is not None:
          prediction_tx = maybe_prediction_tx
        else:
          prediction_tx = spec.predict_next_transaction(reference_tx)
          prediction_tx.prediction_data = PredictionData(PredictionState.PREDICTION, link)
          txs.append(prediction_tx)
          self.transactions.append(prediction_tx)
          changed = True
        if prediction_tx.date <= today:
          matching_txs = [candidate_tx for candidate_tx in self.transactions if not candidate_tx.is_prediction and spec.matches(prediction_tx, candidate_tx)]
          if len(matching_txs) > 1:
            raise errors.MultipleTransactionsMatchPredictionError(prediction=prediction_tx, matches=matching_txs)
          elif len(matching_txs) < 1:
            if prediction_tx.date < today:
              warnings.warn(errors.PredictionResolutionWarning(prediction=prediction_tx))
          else:
            txs.remove(prediction_tx)
            self.transactions.remove(prediction_tx)
            reference_tx.prediction_data = PredictionData(PredictionState.SUPERSEDED, link)
            [matching_tx] = matching_txs
            matching_tx.summary = prediction_tx.summary
            matching_tx.metadata["Predict"] = reference_tx.metadata["Predict"]
            matching_tx.prediction_data = PredictionData(PredictionState.REFERENCE, link)
            txs.append(matching_tx)
            reference_tx = matching_tx
            changed = True

  @staticmethod
  def _get_reference(txs: List[Transaction], link: PredictionLink) -> Transaction:
    for tx in txs:
      assert tx.prediction_data is not None
      if tx.prediction_data.state == PredictionState.REFERENCE:
        return tx
    raise errors.MissingPredictionReferenceError(link=link)

  @staticmethod
  def _get_prediction(txs: List[Transaction]) -> Optional[Transaction]:
    for tx in txs:
      assert tx.prediction_data is not None
      if tx.prediction_data.state == PredictionState.PREDICTION:
        return tx
    return None

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
