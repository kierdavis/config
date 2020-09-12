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
