#!/usr/bin/env python3

# based on https://stackoverflow.com/a/60949722

from pathlib import Path
import subprocess as sp
from typing import Iterable, List
import time

NOW = time.time()
MAX_IDLE_TIME = 4*60*60

def is_socket_open(path: Path) -> bool:
    try:
        proc = sp.run(['socat', '-u', 'OPEN:/dev/null', f'UNIX-CONNECT:{path.resolve()}'])
        is_open = (proc.returncode == 0)
    except FileNotFoundError:
        is_open = False
    return is_open

def sort_by_access_timestamp(entries: Iterable[Path]) -> List:
    entries = [(e.stat().st_atime, e) for e in entries]
    entries = sorted(entries, reverse=True)
    return entries

# There can be garbage sockets
socks = sort_by_access_timestamp(Path('/run/user/1000/').glob('vscode-ipc-*.sock'))

# Only consider the ones that were active N seconds ago
socks = [sock for ts, sock in socks if NOW - ts <= MAX_IDLE_TIME]

# Find the first socket that is open, most recently accessed first
ipc_sock = next((sock for sock in socks if is_socket_open(sock)), None)
if not ipc_sock:
    raise FileNotFoundError('Could not find a suitable VS Code server IPC socket')

# Every entry in ~/.vscode-server/bin is a commit id
# Pick the most recent one
code_repos = sort_by_access_timestamp(Path.home().glob('.vscode-server/bin/*'))
_, code_repo = code_repos[0]

code_binary = code_repo / 'bin' / 'code'

source = f"""
export VSCODE_IPC_HOOK_CLI="{ipc_sock}"
alias code="{code_binary}"
""".strip()

# Output to stdout
print(source)