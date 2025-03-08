#!/usr/bin/env python3

"""
code-connect - A tool for connecting to an existing VS Code instance from arbitrary terminals.

https://github.com/chvolkmann/code-connect
MIT Licensed
"""

import os
import subprocess as sp
import sys
import time
from pathlib import Path
from shutil import which
from typing import Iterable, NoReturn


RUN_DIR = Path(f"/run/user/{os.getuid()}")
VSCODE_IPC_SOCKET_PATTERN = "vscode-ipc-*.sock"

VSCODE_HOME = Path.home() / ".vscode-server"
VSCODE_CODE_BIN_PATTERN = "cli/servers/Stable-*/server/bin/remote-cli/code"


MAX_SOCKET_IDLE_ITEM: float = 4 * 60 * 60
"""
IPC sockets will be filtered based on when they were last accessed.  
This gives an upper bound in seconds to the timestamps
"""


def fail(*msgs: str, retcode: int = 1) -> NoReturn:
    """Prints messages to stdout and exits the script."""
    for msg in msgs:
        print(msg)
    exit(retcode)


def is_socket_alive(path: Path) -> bool:
    """Returns True iff the UNIX socket exists and is currently listening."""
    try:
        # capture output to prevent printing to stdout/stderr
        # https://unix.stackexchange.com/a/556790/106406
        proc = sp.run(
            ["socat", "-u", "OPEN:/dev/null", f"UNIX-CONNECT:{path.resolve()}"],
            stdout=sp.PIPE,
            stderr=sp.PIPE,
        )
        return proc.returncode == 0
    except FileNotFoundError:
        return False


def ensure_socat_is_in_PATH() -> None:
    """Verifies that all required binaries are available in $PATH."""
    if not which("socat"):
        fail(
            '"socat" not found in $PATH, but is required for running code-connect',
            "",
            "Please install it, e.g. using",
            "  sudo apt install socat",
        )


def sort_by_access_timestamp(paths: Iterable[Path]) -> list[tuple[float, Path]]:
    """Returns a list of tuples (last_accessed_ts, path) sorted by the former."""
    return sorted([(p.stat().st_atime, p) for p in paths], reverse=True)


def get_next_open_socket(socks: Iterable[Path]) -> Path:
    """Iterates over the list and returns the first socket that is listening."""
    try:
        return next((sock for sock in socks if is_socket_alive(sock)))
    except StopIteration:
        fail(
            "Could not find any open VS Code IPC socket.",
            "",
            "Please make sure to connect to this machine with a standard VS Code remote SSH session before running code-connect.",
        )


def get_code_bin() -> Path:
    """Returns the path to the most recently accessed code executable."""
    possible_code_bins = [f for f in VSCODE_HOME.glob(VSCODE_CODE_BIN_PATTERN) if f.is_file()]
    if not possible_code_bins:
        fail(
            "No VS Code remote-cli detected!",
            "",
            "Please connect to this machine through a remote SSH session and try again.",
            "Afterwards there should exist a folder under ~/.vscode-server/cli/servers/",
        )

    if len(possible_code_bins) == 0:
        fail(
            "Could not find suitable executable for VS Code",
            "",
            f"Searched: {VSCODE_HOME / VSCODE_CODE_BIN_PATTERN}",
        )

    # select the binary that was most recently accessed
    _, code_bin = sort_by_access_timestamp(possible_code_bins)[0]
    return code_bin


def list_ipc_sockets() -> list[Path]:
    """Returns a list of all possible IPC sockets for the current user."""
    uid = os.getuid()
    return list(Path(f"/run/user/{uid}/").glob("vscode-ipc-*.sock"))


def get_latest_ipc_socket(max_idle_time: float = MAX_SOCKET_IDLE_ITEM) -> Path:
    """Returns the path to the most recently accessed IPC socket."""

    # List all possible sockets for the current user
    # Some of these are obsolete and not actively listening anymore
    uid = os.getuid()
    socket_entries = sort_by_access_timestamp(Path(f"/run/user/{uid}/").glob("vscode-ipc-*.sock"))

    # Only consider the ones that were active N seconds ago
    now = time.time()
    socks = [sock for ts, sock in socket_entries if now - ts <= max_idle_time]

    # Find the first socket that is open, most recently accessed first
    return get_next_open_socket(socks)


def launch_code_over_ipc(
    args: list[str] | None = None,
    max_socket_idle_item: float = MAX_SOCKET_IDLE_ITEM,
) -> int:
    """Runs the code executable with the given arguments."""
    if args is None:
        args = []
    code_bin = get_code_bin()
    latest_ipc_sock = get_latest_ipc_socket(max_idle_time=max_socket_idle_item)
    return sp.run(
        args=[code_bin, *args],
        env={
            **os.environ,
            "VSCODE_IPC_HOOK_CLI": str(latest_ipc_sock),
        },
    ).returncode


if __name__ == "__main__":
    ensure_socat_is_in_PATH()

    # run the code binary with the args of the current script and exit with the same return code
    exit(launch_code_over_ipc(sys.argv[1:]))
