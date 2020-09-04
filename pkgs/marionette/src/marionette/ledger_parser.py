# type: ignore

import datetime
from decimal import Decimal
from pyparsing import *
from .ledger import Transaction, Posting, Ledger

ws = " \t\r"

nonnegative_integer = Word(nums).setParseAction(lambda s, l, t: int(t[0])).setName("nonnegative_integer")
integer = Combine(Optional("-") + Word(nums)).setParseAction(lambda s, l, t: int(t[0])).setName("integer")
decimal = Combine(Optional("-") + Word(nums) + Optional("." + Word(nums))) \
  .setParseAction(lambda s, l, t: Decimal(t[0])).setName("decimal")

date = And([
  nonnegative_integer,
  Suppress(Literal("-").leaveWhitespace()),
  nonnegative_integer.copy().leaveWhitespace(),
  Suppress(Literal("-").leaveWhitespace()),
  nonnegative_integer.copy().leaveWhitespace(),
]).setParseAction(lambda s, l, t: datetime.date(*t)).setName("date")

amount = Suppress(Literal("£")) + decimal.leaveWhitespace().setName("amount")

metadata_key = Word(alphanums).setName("metadata_key")
metadata_key_val = (Word(alphanums) + Suppress(":") + SkipTo(LineEnd())) \
  .setParseAction(lambda s, l, t: [tuple(t)]).setName("metadata_key_val")
metadata_line = And([
  Suppress(LineStart().leaveWhitespace()),
  Suppress(White(ws)),
  Suppress(Literal(";")),
  metadata_key_val | Suppress(SkipTo(LineEnd())),
  Suppress(LineEnd()),
]).setName("metadata_line")
metadata_lines = ZeroOrMore(metadata_line).setParseAction(lambda s, l, t: [dict(iter(t))]).setName("metadata_lines")

posting_line = And([
  Suppress(LineStart().leaveWhitespace()),
  Suppress(White(ws)),
  ...,
  Suppress(White(ws, min=2)),
  amount,
  Optional(Suppress("=") + amount, default=None).setWhitespaceChars(ws),
  Suppress(LineEnd()),
]).setName("posting_line")
posting = (posting_line + metadata_lines).setParseAction(lambda s, l, t: Posting(*t)).setName("posting")

transaction_line = And([
  Suppress(LineStart()),
  date.copy().leaveWhitespace(),
  ...,
  Suppress(LineEnd()),
]).setName("transaction_line")
transaction = (transaction_line + metadata_lines + Group(ZeroOrMore(posting))) \
  .setParseAction(lambda s, l, t: Transaction(*t)).setName("transaction")

ledger = Group(ZeroOrMore(transaction)).setParseAction(lambda s, l, t: Ledger(*t)).setName("ledger")

def parse_string(s):
  [result] = (ledger + Suppress(StringEnd())).parseString(s)
  return result
