import requests
from typing import Any, Dict, List, Callable, Optional, Tuple, Union
from typing_extensions import TypedDict

class _Token(TypedDict, total=False):
  access_token: str
  token_type: str
  expires_in: int
  refresh_token: str
  scope: List[str]

_TokenUpdater = Callable[[_Token], None]

class OAuth2Session(requests.Session):
  def __init__(
    self,
    *,
    client_id: Optional[str] = None,
    # client: Optional[oauthlib.oauth2.Client] = None,
    auto_refresh_url: Optional[str] = None,
    auto_refresh_kwargs: Optional[Dict[str, str]] = None,
    scope: Optional[List[str]] = None,
    redirect_uri: Optional[str] = None,
    token: Optional[_Token] = None,
    state: Optional[str] = None,
    token_updater: Optional[_TokenUpdater] = None,
  ): ...

  def authorization_url(self, url: str, state: Optional[str] = None, **kwargs: str) -> Tuple[str, str]: ...

  def fetch_token(
    self,
    token_url: str,
    *,
    code: Optional[str] = None,
    authorization_response: Optional[str] = None,
    body: str = "",
    auth: Union[None, Tuple[str, str], requests.auth.AuthBase, Callable[[requests.Request], requests.Request]] = None,
    username: Optional[str] = None,
    password: Optional[str] = None,
    method: str = "POST",
    force_querystring: bool = False,
    timeout: Optional[float] = None,
    headers: Optional[Dict[str, str]] = None,
    verify: bool = True,
    # proxies: Optional[MutableMapping[str, str]] = None,
    include_client_id: Optional[bool] = None,
    client_secret: Optional[str] = None,
    # cert = None,
    **kwargs: str,
  ) -> _Token: ...
