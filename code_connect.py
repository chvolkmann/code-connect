#!/usr/bin/env python3

# based on https://stackoverflow.com/a/60949722

from pathlib import Path
import subprocess as sp
from typing import Iterable, List, Tuple
import time

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

def main(max_idle_time: int = MAX_IDLE_TIME):
    # List all possible sockets
    # Some of these are obsolete and not listening
    socks = sort_by_access_timestamp(Path('/run/user/1000/').glob('vscode-ipc-*.sock'))

    # Only consider the ones that were active N seconds ago
    now = time.time()
    socks = [sock for ts, sock in socks if now - ts <= max_idle_time]

    # Find the first socket that is open, most recently accessed first
    ipc_sock = next_open_socket(socks)

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

    code_binary = code_repo / 'bin' / 'code'

    # Output a shell string to stdout
    source = '\n'.join([
        f'# source this into your shell of choice',
        f'export VSCODE_IPC_HOOK_CLI="{ipc_sock}"',
        f'alias code="{code_binary}"'
    ])
    print(source)

if __name__ == '__main__':
    main()