import argparse
import logging
import shutil
import subprocess
import tempfile
import weakref
from pathlib import Path
from types import TracebackType
from typing import TYPE_CHECKING, NamedTuple, Optional, Set, Type

if TYPE_CHECKING:
    TemporaryDirectory = tempfile.TemporaryDirectory[str]
else:
    TemporaryDirectory = tempfile.TemporaryDirectory


class Abort(Exception):
    pass


class ChannelUrl:
    __slots__ = ("base",)

    def __init__(self, base: str):
        self.base = base.rstrip("/")

    def __str__(self) -> str:
        return self.base

    @property
    def nixexprs(self) -> str:
        return f"{self.base}/nixexprs.tar.xz"


Config = NamedTuple(
    "Config",
    [
        ("upstream_channel_url", ChannelUrl),
        ("expression", Optional[Path]),
        ("downstream_channel_dir", Path),
    ],
)


class MaybeKeepTemporaryDirectory(TemporaryDirectory):
    # # Undocumented property of parent class
    _finalizer: weakref.finalize

    def __exit__(
        self,
        exc: Optional[Type[BaseException]],
        value: Optional[BaseException],
        tb: Optional[TracebackType],
    ) -> bool:
        if exc is not None:
            self._finalizer.detach()
            return False
        return super().__exit__(exc, value, tb)


def download_nixexprs(url: ChannelUrl, dest: Path) -> None:
    logging.info("downloading upstream nixexprs.tar.xz at %s to %s", url.nixexprs, dest)
    dest.parent.mkdir(parents=True, exist_ok=True)
    try:
        subprocess.run(
            ["curl", "--location", "--output", dest, url.nixexprs],
            stderr=subprocess.PIPE,
            encoding="utf-8",
            check=True,
        )
    except subprocess.CalledProcessError as e:
        raise Abort("failed to download upstream channel using curl") from e


def unpack_nixexprs(archive: Path, unpack_dir: Path) -> None:
    logging.info("unpacking nixexprs.tar.xz into %s", unpack_dir)
    unpack_dir.mkdir(parents=True, exist_ok=True)
    try:
        subprocess.run(
            ["tar", "--extract", "--xz", "--file", archive],
            cwd=unpack_dir,
            stderr=subprocess.PIPE,
            encoding="utf-8",
            check=True,
        )
    except subprocess.CalledProcessError as e:
        raise Abort("failed to unpack upstream channel using tar") from e


def find_nixpkgs(unpack_dir: Path) -> Path:
    children = list(unpack_dir.iterdir())
    n = len(children)
    if n != 1:
        raise Abort(
            f"unpacked channel produced {n} directory entries, but we expected 1"
        )
    nixpkgs = children[0]
    logging.info("nixpkgs is at %s", nixpkgs)
    return nixpkgs


def build_expression(nixpkgs: Path, expression: Path, nix_build_log: Path) -> Set[Path]:
    logging.info("pre-building %s", expression)
    logging.info("nix-build logs are being saved to %s", nix_build_log)
    try:
        with open(nix_build_log, "w") as nix_build_log_file:
            result = subprocess.run(
                ["nix-build", "--no-out-link", "-I", f"nixpkgs={nixpkgs}", expression],
                stdout=subprocess.PIPE,
                stderr=nix_build_log_file,
                encoding="utf-8",
                check=True,
            )
    except subprocess.CalledProcessError as e:
        raise Abort(f"failed to build expression; log saved to {nix_build_log}") from e
    return {Path(store_path) for store_path in result.stdout.strip().split()}


def publish_channel(nixexprs: Path, channel_dir: Path) -> None:
    dest = channel_dir / "nixexprs.tar.xz"
    logging.info("publishing nixexprs.tar.xz to %s", dest)
    dest.parent.mkdir(parents=True, exist_ok=True)
    try:
        nixexprs.replace(dest)
    except Exception as e:
        logging.warning("failed to move (%s), trying to copy instead", e)
        shutil.copyfile(nixexprs, dest)


def sync(config: Config) -> None:
    with MaybeKeepTemporaryDirectory(prefix="tmp-nix-channel-proxy-") as temp_dir_str:
        temp_dir = Path(temp_dir_str)
        logging.info("using temporary directory at %s", temp_dir)
        nixexprs = temp_dir / "nixexprs.tar.xz"
        unpack_dir = temp_dir / "unpack"
        download_nixexprs(config.upstream_channel_url, nixexprs)
        unpack_nixexprs(nixexprs, unpack_dir)
        nixpkgs = find_nixpkgs(unpack_dir)
        if config.expression is not None:
            build_expression(nixpkgs, config.expression, temp_dir / "nix-build.log")
        publish_channel(nixexprs, config.downstream_channel_dir)
        logging.info("done")


def parse_cmdline() -> Config:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "upstream",
        help="URL of upstream channel e.g. https://nixos.org/channels/nixos-19.03",
    )
    parser.add_argument(
        "downstream", help="directory in which to create resulting channel"
    )
    parser.add_argument(
        "-e",
        "--expression",
        default=None,
        help="path to a nix file which will be built before publishing the channel",
    )
    args = parser.parse_args()
    return Config(
        upstream_channel_url=ChannelUrl(args.upstream),
        expression=(Path(args.expression) if args.expression else None),
        downstream_channel_dir=Path(args.downstream),
    )


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    sync(parse_cmdline())


if __name__ == "__main__":
    main()
