#!/usr/bin/env python3

# based on https://stackoverflow.com/a/60949722

import time
import subprocess as sp
import os
from distutils.spawn import find_executable
from typing import Iterable, List, Tuple
from pathlib import Path
import sys

MAX_IDLE_TIME = 4 * 60 * 60

def fail(*msgs, retcode=1):
    for msg in msgs:
        print(msg)
    exit(retcode)

def is_socket_open(path: Path) -> bool:
    try:
        # capture output to prevent printing to stdout/stderr
        proc = sp.run(['socat', '-u', 'OPEN:/dev/null', f'UNIX-CONNECT:{path.resolve()}'], capture_output=True)
        return (proc.returncode == 0)
    except FileNotFoundError:
        return False

def sort_by_access_timestamp(paths: Iterable[Path]) -> List[Tuple[float, Path]]:
    paths = [(p.stat().st_atime, p) for p in paths]
    paths = sorted(paths, reverse=True)
    return paths

def next_open_socket(socks: Iterable[Path]) -> Path:
    try:
        return next((sock for sock in socks if is_socket_open(sock)))
    except StopIteration:
        fail(
            'Could not find an open VS Code IPC socket.',
            '',
            'Please make sure to connect to this machine with a standard VS Code remote SSH session before using this tool.'
        )

def check_for_binaries():
    if not find_executable('socat'):
        fail(
            '"socat" not found in $PATH, but is required for code-connect'
        )

def get_code_binary() -> Path:
    # Every entry in ~/.vscode-server/bin corresponds to a commit id
    # Pick the most recent one
    code_repos = sort_by_access_timestamp(Path.home().glob('.vscode-server/bin/*'))
    if len(code_repos) == 0:
        fail(
            'No installation of VS Code Server detected!',
            '',
            'Please connect to this machine through a remote SSH session and try again.',
            'Afterwards there should exist a folder under ~/.vscode-server'
        )

    _, code_repo = code_repos[0]
    return code_repo / 'bin' / 'code'

def get_ipc_socket(max_idle_time: int = MAX_IDLE_TIME) -> Path:
    # List all possible sockets for the current user
    # Some of these are obsolete and not actively listening anymore
    uid = os.getuid()
    socks = sort_by_access_timestamp(Path(f'/run/user/{uid}/').glob('vscode-ipc-*.sock'))

    # Only consider the ones that were active N seconds ago
    now = time.time()
    socks = [sock for ts, sock in socks if now - ts <= max_idle_time]

    # Find the first socket that is open, most recently accessed first
    return next_open_socket(socks)

def main(max_idle_time: int = MAX_IDLE_TIME):
    check_for_binaries()

    # Fetch the path of the "code" executable
    # and determine an active IPC socket to use
    code_binary = get_code_binary()
    ipc_socket = get_ipc_socket()

    args = sys.argv.copy()
    args[0] = str(code_binary)
    os.environ['VSCODE_IPC_HOOK_CLI'] = str(ipc_socket)

    # run the "code" executable with the proper environment variable set
    # stdout/stderr remain connected to the current process
    proc = sp.run(args)

    # return the same exit code as the wrapped process
    exit(proc.returncode)

if __name__ == '__main__':
    main()