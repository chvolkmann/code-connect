# code-connect

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/chvolkmann/code-connect?label=version&style=flat-square)

Open a file in your locally running Visual Studio Code instance from arbitrary terminal connections.

## Motivation

VS Code supports opening files with the terminal using `code /path/to/file`. While this is possible in [WSL sessions](https://code.visualstudio.com/docs/remote/wsl) and [remote SSH sessions](https://code.visualstudio.com/docs/remote/ssh) if the integrated terminal is used, it is currently not possible for arbitrary terminal sessions.

Say, you have just SSH'd into a remote server using your favorite terminal and would like to open a webserver config file in your local VS Code instance. So you type `code nginx.conf`, which doesn't work in this terminal. If you try to run `code nginx.conf` in the integrated terminal however, VS Code opens the file just fine.

The aim of this project is to make the `code` cli available to _any_ terminal, not only to VS Code's integrated terminal.

## Prerequisites

- **Linux** - we make assumptions on where VS Code stores its data based on Linux

  > Macs could also support everything out of the box, confirmation needed. Please don't hesitate to come into contact if you have any information to share.

- **Python 3**
  > Tested under Python 3.8, but slightly older versions should work fine
- **socat** - used for pinging UNIX sockets
  ```bash
  apt-get install socat
  ```

### Visual Studio Code Server

You need to set up the server component of VS Code on the machine before using this utility. For this, [connect to your target in a remote SSH session](https://code.visualstudio.com/docs/remote/ssh).

Afterwards, you should have a folder `.vscode-server` in your home directory.

## Installation

### [Fish](https://fishshell.com/)

#### Installing

With [fisher](https://github.com/jorgebucaran/fisher)

```fish
fisher install chvolkmann/code-connect
```

This downloads [`code_connect.py`](./bin/code_connect.py) along with two functions. See [`functions/code.fish`](./functions/code.fish) and [`functions/code-connect.fish`](./functions/code-connect.fish)

You can autocomplete the repository name in subsequent commands, e.g. `fisher update code<TAB>`

#### Updating

```fish
fisher update chvolkmann/code-connect
```

#### Uninstalling

```fish
fisher remove chvolkmann/code-connect
```

### Bash

#### Installing & Updating

With [`bash/install.sh`](./bash/install.sh)

```bash
curl -sS https://raw.githubusercontent.com/chvolkmann/code-connect/main/bash/install.sh | bash
```

This downloads [`code_connect.py`](./bin/code_connect.py) along with two scripts and sets up aliases in your `.bashrc` for you. See [`bash/code.sh`](./bash/code.sh) and [`bash/code-connect.sh`](./bash/code-connect.sh)

#### Uninstalling

With [`bash/uninstall.sh`](./bash/uninstall.sh)

```bash
curl -sS https://raw.githubusercontent.com/chvolkmann/code-connect/main/bash/uninstall.sh | bash
```

Deletes the aliases from `~/.bashrc` and removes the folder `~/.code-connect`

## Usage

Use `code` as you would normally!

If you have VS Code installed on your remote machine as well (i.e. a `code` executable already exists), you can use `code` for your local instance and `code-connect` for an IPC connected instance.

```
Usage: code [options][paths...]

To read from stdin, append '-' (e.g. 'ps aux | grep code | code -')

Options
  -d --diff <file> <file>           Compare two files with each other.
  -a --add <folder>                 Add folder(s) to the last active window.
  -g --goto <file:line[:character]> Open a file at the path on the specified line and character position.
  -n --new-window                   Force to open a new window.
  -r --reuse-window                 Force to open a file or folder in an already opened window.
  -w --wait                         Wait for the files to be closed before returning.
  -h --help                         Print usage.

Troubleshooting
  -v --version Print version.
  -s --status  Print process usage and diagnostics information.
```

## Changelog

See [CHANGELOG.md](./CHANGELOG.md)

## How it works

### VS Code Remote under the hood

VS Code uses datagram sockets to communicate between a terminal and the rendering window.

The integrated terminal as well as the WSL terminal spawn an IPC socket. You also create one when connecting through a remote SSH session. These sockets can be found in the folders of VS Code Server.

Each time you connect remotely, the VS Code client instructs the server to fetch the newest version of itself. All versions are stored by commit id in `~/.vscode-server/bin`. `code-connect` uses the version that has been most recently accessed. The corresponding `code` executable can be found in `~/.vscode-server/bin/<commid-id>/bin/code`.

A similar method is used to list all of VS Code's IPC sockets, which are located under `/run/user/<userid>/vscode-ipc-<UUID>.sock`, where `<userid>` is the [current user's UID](https://en.wikipedia.org/wiki/User_identifier) and `<UUID>` is a unique ID. VS Code does not seem to clean up all stale connections, so some of these sockets are active, some are not.

Thus the first socket that is listening and that was accessed within a timeframe of 4 hours by default is chosen.

VS Code communicates the presence of an active IPC connection with the environment variable `VSCODE_IPC_HOOK_CLI` which stores the path to the socket.

You can verify this by opening a connection to your remote machine. In one case, you use VS Code's integrated terminal. In the other case, you use any other terminal.

Run

```bash
echo $VSCODE_IPC_HOOK_CLI
```

which displays an output in the integrated terminal, but not on the other one.

In order, every socket is checked to see if it is listening. For this, the following snippet based on [this answer on StackOverflow](https://unix.stackexchange.com/a/556790) was used.

```bash
socat -u OPEN:/dev/null UNIX-CONNECT:/path/to/socket
```

This returns `0` if and only if there's something listening.

### `code-connect` under the hood

The script `code_connect.py` performs all of the above steps and runs the VS Code `code` executable
as a child process with `VSCODE_IPC_HOOK_CLI` set properly, making it a drop-in replacement for `code`.

When we already have a `code` executable available, we don't need to search for it ourselves using `code_connect.py`. So we introduce two more scripts:

- `code-connect`  
  Direct alias to `code_connect.py`
- `code`  
  Checks whether there is a `code` executable locally installed already and tries to use it if available. Otherwise, `code-connect` will be used.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## Credit

- Based on an [answer on StackOverflow](https://stackoverflow.com/a/60949722) by [stabledog](https://stackoverflow.com/users/237059/Stabledog)
