#!/usr/bin/env python3

# https://github.com/chvolkmann/code-connect

import os
import subprocess as sp
import sys
import time
from pathlib import Path
from shutil import which
from typing import Iterable, List, NoReturn, Sequence, Tuple

# IPC sockets will be filtered based when they were last accessed
# This gives an upper bound in seconds to the timestamps
DEFAULT_MAX_IDLE_TIME: int = 4 * 60 * 60


def fail(*msgs, retcode: int = 1) -> NoReturn:
    """ Prints messages to stdout and exits the script. """
    for msg in msgs:
        print(msg)
    exit(retcode)


def is_socket_open(path: Path) -> bool:
    """ Returns True iff the UNIX socket exists and is currently listening. """
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


def sort_by_access_timestamp(paths: Iterable[Path]) -> List[Tuple[float, Path]]:
    """ Returns a list of tuples (last_accessed_ts, path) sorted by the former. """
    return sorted([(p.stat().st_atime, p) for p in paths], reverse=True)


def next_open_socket(socks: Sequence[Path]) -> Path:
    """ Iterates over the list and returns the first socket that is listening. """
    try:
        return next((sock for sock in socks if is_socket_open(sock)))
    except StopIteration:
        fail(
            "Could not find an open VS Code IPC socket.",
            "",
            "Please make sure to connect to this machine with a standard "
            + "VS Code remote SSH session before using this tool.",
        )


def check_for_binaries() -> None:
    """ Verifies that all required binaries are available in $PATH. """
    if not which("socat"):
        fail('"socat" not found in $PATH, but is required for code-connect')


def get_code_binary() -> Path:
    """ Returns the path to the most recently accessed code executable. """

    # Every entry in ~/.vscode-server/bin corresponds to a commit id
    # Pick the most recent one
    code_bins = []
    for root, dirs, files in os.walk(str(Path.home()) + "/.vscode-server/"):
        if "code" in files:
            result = sp.run([root+"/code"], stdout=sp.PIPE, stderr=sp.PIPE)
            if result.stdout == b'Command is only available in WSL or inside a Visual Studio Code terminal.\n':
                code_bins += [Path(root+"/code")]

    if len(code_bins) == 0:
        fail(
            "No VS Code remote-cli detected!",
            "",
            "Please connect to this machine through a remote SSH session and try again.",
            "Afterwards there should exist a folder under ~/.vscode-server/cli/servers/",
        )

    _, code_bin = sort_by_access_timestamp(code_bins)[0]

    return code_bin


def get_ipc_socket(max_idle_time: int = DEFAULT_MAX_IDLE_TIME) -> Path:
    """ Returns the path to the most recently accessed IPC socket. """

    # List all possible sockets for the current user
    # Some of these are obsolete and not actively listening anymore
    uid = os.getuid()
    socks = sort_by_access_timestamp(Path(f"/run/user/{uid}/").glob("vscode-ipc-*.sock"))

    # Only consider the ones that were active N seconds ago
    now = time.time()
    socks = [sock for ts, sock in socks if now - ts <= max_idle_time]

    # Find the first socket that is open, most recently accessed first
    return next_open_socket(socks)


def main(max_idle_time: int = DEFAULT_MAX_IDLE_TIME) -> NoReturn:
    """ Calls the code executable as a subprocess with the environment set up properly. """
    check_for_binaries()

    # Fetch the path of the "code" executable
    # and determine an active IPC socket to use
    code_binary = get_code_binary()
    ipc_socket = get_ipc_socket(max_idle_time)

    args = sys.argv.copy()
    args[0] = str(code_binary)
    os.environ["VSCODE_IPC_HOOK_CLI"] = str(ipc_socket)

    # run the "code" executable with the proper environment variable set
    # stdout/stderr remain connected to the current process
    proc = sp.run(args)

    # return the same exit code as the wrapped process
    exit(proc.returncode)


if __name__ == "__main__":
    main()
