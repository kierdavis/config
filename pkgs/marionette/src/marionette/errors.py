from decimal import Decimal
from dataclasses import dataclass
from typing import List, TYPE_CHECKING

if TYPE_CHECKING:
  from . import monzo, ledger
  from .ledger import Amount, Account

class IntegrityError(Exception):
  pass

@dataclass
class LedgerAmountDoesNotMatchMonzo(IntegrityError):
  ledger_tx: "ledger.Transaction"
  monzo_txs: List["monzo.Transaction"]
  account: "Account"
  ledger_amount: "Amount"
  monzo_amount: "Amount"
  def __str__(self) -> str:
    return f"discrepency in the total amount posted to account {self.account} in transaction '{self.ledger_tx.short_str}': monzo says £{self.monzo_amount:2f} but ledger says £{self.ledger_amount:2f}"

@dataclass
class PostingElisionError(IntegrityError):
  tx: "ledger.Transaction"
  def __str__(self) -> str:
    return f"at most one posting in transaction '{self.tx.short_str}' may have an elided amount"

@dataclass
class UnbalancedTransactionError(IntegrityError):
  tx: "ledger.Transaction"
  actual_sum: Decimal
  def __str__(self) -> str:
    return f"postings in transaction '{self.tx.short_str}' do not sum to zero (they sum to £{self.actual_sum:2f} instead)"

@dataclass
class OverusedPredictionLinkError(IntegrityError):
  link: str
  txs: List["ledger.Transaction"]
  def __str__(self) -> str:
    return f"prediction link {self.link!r} is used more than twice: {', '.join(tx.short_str for tx in self.txs)}"

@dataclass
class MultipleTransactionsMatchPredictionError(IntegrityError):
  prediction: "ledger.Transaction"
  matches: List["ledger.Transaction"]
  def __str__(self) -> str:
    return f"multiple transactions match prediction '{self.prediction.short_str}': {', '.join(tx.short_str for tx in self.matches)}"

@dataclass
class PredictionResolutionWarning(Warning, IntegrityError):
  prediction: "ledger.Transaction"
  def __str__(self) -> str:
    return f"prediction '{self.prediction.short_str}' is in the past but could not be resolved against any concrete transactions"

class LedgerSyntaxError(SyntaxError):
  pass

@dataclass
class InvalidPredictionSpecError(LedgerSyntaxError):
  tx: "ledger.Transaction"
  input: str
  def __str__(self) -> str:
    return f"invalid prediction specification in transaction '{self.tx.short_str}': {self.input}"

class MonzoAPIError(Exception):
  pass

@dataclass
class UnexpectedCurrencyError(MonzoAPIError):
  tx: "monzo.Transaction"
  @property
  def currency(self) -> str:
    return self.tx.get("currency", "")
  def __str__(self) -> str:
    return f"monzo API returned a transaction {self.tx['id']} with unexpected currency {self.currency!r}"
