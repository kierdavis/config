import re
from . import ledger
from .monzo import Category
from typing import Optional

def monzo_category_for_transaction(tx: ledger.Transaction) -> Optional[Category]:
  counter_account = tx.counter_account
  if counter_account is not None:
    return monzo_category_for_account(counter_account)
  return None

def monzo_category_for_account(acc: ledger.Account) -> Category:
  if re.match("^Expenses:Charity\\b", acc):
    return Category("charity")
  elif re.match("^Expenses:Essential:Bills\\b", acc):
    return Category("bills")
  elif re.match("^Expenses:Essential:Food\\b", acc):
    return Category("groceries")
  elif re.match("^Expenses:Essential:Home\\b", acc):
    return Category("family")
  elif re.match("^Expenses:Essential:Travel\\b", acc):
    return Category("transport")
  elif re.match("^Expenses:Gifts\\b", acc):
    return Category("gifts")
  elif re.match("^Expenses:Hobbies\\b", acc):
    return Category("entertainment")
  elif re.match("^Expenses:SelfCare:Food\\b", acc):
    return Category("eating_out")
  elif re.match("^Expenses:SelfCare:NonEssentialTravel\\b", acc):
    return Category("transport")
  elif re.match("^Expenses:SelfCare\\b", acc):
    return Category("personal_care")
  else:
    return Category("general")
