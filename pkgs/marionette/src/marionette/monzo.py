import os
import json
import time
import logging
import webbrowser
import threading
import datetime
import requests
from queue import Queue
from decimal import Decimal
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
from requests_oauthlib import OAuth2Session
from typing import Any, TYPE_CHECKING, Tuple, Optional, cast, NewType, List
from typing_extensions import TypedDict
from . import errors
from urllib.parse import parse_qs

if TYPE_CHECKING:
  from requests_oauthlib.oauth2_session import _Token as Token
else:
  Token = dict

AUTH_TOKEN_PATH = Path.home() / ".marionette" / "auth_token.json"
SERVER_PORT = 9898

AccountId = NewType("AccountId", str)
MerchantId = NewType("MerchantId", str)
PotId = NewType("PotId", str)
TransactionId = NewType("TransactionId", str)
Category = NewType("Category", str)

class Account(TypedDict, total=False):
  id: AccountId

class AccountBalance(TypedDict, total=False):
  balance: int
  total_balance: int
  currency: str
  spend_today: int

class Merchant(TypedDict, total=False):
  id: MerchantId
  name: str

class Pot(TypedDict, total=False):
  id: PotId
  name: str

class TransactionMetadata(TypedDict, total=False):
  pot_id: PotId

class Transaction(TypedDict, total=False):
  id: TransactionId
  created: str
  description: str
  amount: int
  currency: str
  merchant: Optional[Merchant]
  notes: str
  category: Category
  metadata: TransactionMetadata
  decline_reason: str

class TransactionUtil:
  @staticmethod
  def timestamp(tx: Transaction) -> datetime.datetime:
    return datetime.datetime.strptime(tx["created"], "%Y-%m-%dT%H:%M:%S.%f%z")
  
  @staticmethod
  def amount(tx: Transaction) -> Decimal:
    if tx["currency"] != "GBP":
      raise errors.UnexpectedCurrencyError(tx=tx)
    return Decimal(tx["amount"]) / Decimal(100)

  @staticmethod
  def merchant(tx: Transaction) -> Merchant:
    return tx.get("merchant") or {}

class Monzo:
  def __init__(self, session: OAuth2Session):
    self._session = session
    self.account_id = self.accounts()[0]["id"]
  
  @classmethod
  def login(cls) -> "Monzo":
    client_id = os.environ["MONZO_CLIENT_ID"]
    client_secret = os.environ["MONZO_CLIENT_SECRET"]
    token = load_auth_token()
    session = OAuth2Session(
      client_id=client_id,
      redirect_uri=f"http://localhost:{SERVER_PORT}/",
      token=token,
      auto_refresh_url="https://api.monzo.com/oauth2/token",
      auto_refresh_kwargs={
        "client_id": client_id,
        "client_secret": client_secret,
      },
      token_updater=save_auth_token,
    )

    if token is None:
      authorization_url, csrf_token = session.authorization_url("https://auth.monzo.com/")

      server = LoginServer(("localhost", SERVER_PORT), csrf_token)
      server_thread = threading.Thread(target=server.serve_forever)
      server_thread.start()

      try:
        logging.info(f"Opening {authorization_url} in browser.")
        webbrowser.open(authorization_url)

        code = server.code_queue.get(block=True)
        logging.debug(f"Got callback url: {code}")
        token = session.fetch_token(
          token_url="https://api.monzo.com/oauth2/token",
          code=code,
          include_client_id=True,
          client_secret=client_secret,
        )
        save_auth_token(token)

      finally:
        server.shutdown()

    return cls(session)

  def accounts(self) -> List[Account]:
    raw = self._check(self._session.get("https://api.monzo.com/accounts")).json()["accounts"]
    return cast(List[Account], raw)

  def balance(self) -> Decimal:
    params = {"account_id": self.account_id}
    raw = self._check(self._session.get("https://api.monzo.com/balance", params=params)).json()
    amount_int = cast(AccountBalance, raw)["balance"]
    return Decimal(amount_int) / Decimal(100)

  def pots(self) -> List[Pot]:
    params = {"current_account_id": self.account_id}
    raw = self._check(self._session.get("https://api.monzo.com/pots", params=params)).json()["pots"]
    return cast(List[Pot], raw)

  def transactions(self) -> List[Transaction]:
    params = {
      "account_id": self.account_id,
      "since": (datetime.datetime.now() - datetime.timedelta(days=89)).strftime("%Y-%m-%dT%H:%M:%SZ"),
      "expand[]": "merchant",
    }
    raw = self._check(self._session.get("https://api.monzo.com/transactions", params=params)).json()["transactions"]
    return cast(List[Transaction], raw)

  def patch_transaction(self, id: TransactionId, **data: str) -> None:
    print(f"PATCH {id} {data}")
    self._check(self._session.patch(f"https://api.monzo.com/transactions/{id}", data=data))

  def _check(self, resp: requests.Response) -> requests.Response:
    time.sleep(0.5)  # poor man's rate limit
    if resp.status_code != 200:
      raise errors.MonzoAPIHTTPError(
        method = resp.request.method or "?",
        url = resp.request.url or "?",
        status = resp.status_code,
        body = resp.text,
      )
    return resp

def load_auth_token() -> Optional[Token]:
  if AUTH_TOKEN_PATH.exists():
    with AUTH_TOKEN_PATH.open("r") as f:
      return cast(Token, json.load(f))
  return None

def save_auth_token(token: Token) -> None:
  logging.debug(f"Saving token: {token}")
  AUTH_TOKEN_PATH.parent.mkdir(parents=True, exist_ok=True)
  with AUTH_TOKEN_PATH.open("w") as f:
    json.dump(token, f)

class LoginServer(HTTPServer):
  def __init__(self, addr: Tuple[str, int], csrf_token: str):
    super().__init__(addr, LoginRequestHandler)
    self.csrf_token = csrf_token
    self.code_queue: Queue[str] = Queue()

class LoginRequestHandler(BaseHTTPRequestHandler):
  def do_GET(self) -> None:
    server = cast(LoginServer, self.server)
    try:
      _, query_string = self.path.split("?", 1)
    except ValueError:
      self.send_error(404)
      return
    query = parse_qs(query_string)
    if query.get("state", [""])[0] != server.csrf_token:
      self.send_error(400, "CSRF token mismatch")
      return
    code = query.get("code", [""])[0]
    if not code:
      self.send_error(400, "Missing code")
      return
    self.send_header("content-type", "text/plain")
    self.end_headers()
    self.wfile.write(b"Login complete. You can close this tab and return to the application.\r\n")
    server.code_queue.put(code)
    time.sleep(0.5) # ???
