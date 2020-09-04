# type: ignore

from pytest import raises
from datetime import date
from decimal import Decimal
from marionette import ledger_parser as lp
from marionette.ledger import Transaction, Posting, Ledger
from pyparsing import ParseException, StringEnd
from testfixtures import compare

def test_date() -> None:
  compare_parse(lp.date, "2020-06-10", expected=[date(2020, 6, 10)])
  compare_parse(lp.date, " 2020-06-10", expected=[date(2020, 6, 10)])
  compare_parse(lp.date, "2020 -06-10", expected=ParseException)
  compare_parse(lp.date, "2020- 06-10", expected=ParseException)
  compare_parse(lp.date, "2020-06 -10", expected=ParseException)
  compare_parse(lp.date, "2020-06- 10", expected=ParseException)
  compare_parse(lp.date, "2020-06-10 ", expected=[date(2020, 6, 10)])

def test_amount() -> None:
  compare_parse(lp.amount, "£123", expected=[Decimal("123")])
  compare_parse(lp.amount, "£1.23", expected=[Decimal("1.23")])
  compare_parse(lp.amount, "£1.2.3", expected=ParseException)
  compare_parse(lp.amount, "£-123", expected=[Decimal("-123")])
  compare_parse(lp.amount, "£-1.23", expected=[Decimal("-1.23")])
  compare_parse(lp.amount, "£ 123", expected=ParseException)
  compare_parse(lp.amount, "123", expected=ParseException)

def test_posting() -> None:
  compare_parse(lp.posting, "  Assets:Monzo  £123\n", expected=[Posting("Assets:Monzo", Decimal("123"))])
  compare_parse(lp.posting, "Assets:Monzo  £123\n", expected=ParseException)
  compare_parse(lp.posting, "  Assets:Monzo £123\n", expected=ParseException)
  compare_parse(lp.posting, "  Assets:Monzo  £123\n    ; Foobar\n", expected=[Posting("Assets:Monzo", Decimal("123"))])
  compare_parse(lp.posting, "  Assets:Monzo  £123\n    ; Foo: bar\n", expected=[Posting("Assets:Monzo", Decimal("123"), metadata={"Foo": "bar"})])
  compare_parse(lp.posting, "  Assets:Monzo  £123=£456\n", expected=[Posting("Assets:Monzo", Decimal("123"), balance_assertion=Decimal("456"))])
  compare_parse(lp.posting, "  Assets:Monzo  £123 = £456\n", expected=[Posting("Assets:Monzo", Decimal("123"), balance_assertion=Decimal("456"))])
  compare_parse(lp.posting, "  Assets:Monzo  £123  =  £456\n", expected=[Posting("Assets:Monzo", Decimal("123"), balance_assertion=Decimal("456"))])
  compare_parse(lp.posting, "  Assets:Monzo  £123 =\n", expected=ParseException)
  compare_parse(lp.posting, "  Assets:Monzo  £123 = £456\n    ; Foo: bar\n", expected=[Posting("Assets:Monzo", Decimal("123"), balance_assertion=Decimal("456"), metadata={"Foo": "bar"})])

def test_transaction() -> None:
  compare_parse(lp.transaction, "2020-06-10 Starbucks\n", expected=[Transaction(date(2020, 6, 10), "Starbucks")])
  compare_parse(lp.transaction, " 2020-06-10 Starbucks\n", expected=ParseException)
  compare_parse(lp.transaction, "2020-06-10 Starbucks\n  Assets:Monzo  £-6\n", expected=[
    Transaction(date(2020, 6, 10), "Starbucks", postings=[Posting("Assets:Monzo", Decimal("-6"))]),
  ])
  compare_parse(lp.transaction, "2020-06-10 Starbucks\n\n  Assets:Monzo  £-6\n", expected=[
    Transaction(date(2020, 6, 10), "Starbucks", postings=[Posting("Assets:Monzo", Decimal("-6"))]),
  ])
  compare_parse(lp.transaction, "2020-06-10 Starbucks\n  ; Foobar\n  Assets:Monzo  £-6\n", expected=[
    Transaction(date(2020, 6, 10), "Starbucks", postings=[Posting("Assets:Monzo", Decimal("-6"))]),
  ])
  compare_parse(lp.transaction, "2020-06-10 Starbucks\n  ; Foo: bar\n  Assets:Monzo  £-6\n", expected=[
    Transaction(date(2020, 6, 10), "Starbucks", metadata={"Foo": "bar"}, postings=[Posting("Assets:Monzo", Decimal("-6"))]),
  ])
  compare_parse(lp.transaction, "2020-06-10 Starbucks\n  Assets:Monzo  £-6\n  ; Foo: bar\n", expected=[
    Transaction(date(2020, 6, 10), "Starbucks", postings=[Posting("Assets:Monzo", Decimal("-6"), metadata={"Foo": "bar"})]),
  ])

def test_ledger() -> None:
  compare_parse(lp.ledger, "", expected=[Ledger()])
  compare_parse(lp.ledger, "2020-06-10 Starbucks\n  Assets:Monzo  £-6\n", expected=[Ledger([
    Transaction(date(2020, 6, 10), "Starbucks", postings=[Posting("Assets:Monzo", Decimal("-6"))]),
  ])])
  compare_parse(lp.ledger, "2020-06-10 Starbucks\n  Assets:Monzo  £-6\n2020-06-11 Costa\n  Assets:Monzo  £-5\n", expected=[Ledger([
    Transaction(date(2020, 6, 10), "Starbucks", postings=[Posting("Assets:Monzo", Decimal("-6"))]),
    Transaction(date(2020, 6, 11), "Costa", postings=[Posting("Assets:Monzo", Decimal("-5"))]),
  ])])
  compare_parse(lp.ledger, "2020-06-10 Starbucks\n  Assets:Monzo  £-6\n\n2020-06-11 Costa\n  Assets:Monzo  £-5\n", expected=[Ledger([
    Transaction(date(2020, 6, 10), "Starbucks", postings=[Posting("Assets:Monzo", Decimal("-6"))]),
    Transaction(date(2020, 6, 11), "Costa", postings=[Posting("Assets:Monzo", Decimal("-5"))]),
  ])])

def compare_parse(parser, input, *, expected):
  total_parser = parser + StringEnd()
  if expected is ParseException:
    with raises(ParseException):
      total_parser.parseString(input)
  else:
    compare(total_parser.parseString(input), expected=expected)
