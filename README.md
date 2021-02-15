# code-connect

Open a file in your locally running Visual Studio Code instance from arbitrary terminal connections.

## Motivation

VS Code supports opening files with the terminal using `code /path/to/file`. While this is possible in [WSL sessions](https://code.visualstudio.com/docs/remote/wsl) and [remote SSH sessions](https://code.visualstudio.com/docs/remote/ssh) if the integrated terminal is used, it is currently not possible for arbitrary terminal sessions.

Say, you have just SSH'd into a remote server using your favorite terminal and would like to open a webserver config file in your local VS Code instance. So you type `code nginx.conf`, which doesn't work in this terminal. If you try to run `code nginx.conf` in the integrated terminal however, VS Code opens it the file just fine.

The aim of this project is to make the `code` cli available to _any_ terminal, not only to VS Code's integrated terminal.

## Prerequisites

- **Linux** - we make assumptions on where VS Code stores it data based on Linux

  > Macs could also support everything out of the box, confirmation needed. Please don't hesitate to come into contact if you have any information to share.

- **Python 3** - _tested under Python 3.8, but slightly older versions should work fine_
- **socat** - used for pinging UNIX sockets
  ```bash
  apt-get install socat
  ```

### VS Code Server

You need to set up VS Code Server before using this utility. For this, [connect to your target in a remote SSH session](https://code.visualstudio.com/docs/remote/ssh).  
Afterwards, you should have a folder `.vscode-server` in your home directory.

## Usage

Set up an alias for `code`, pointing to `code_connect.py` by placing the following line in your shell's rcfile. That's it, you can now use `code` the usual way.

```bash
alias code="/path/to/code_connect.py"
```

- For **bash**, use `~/.bashrc`.

- For **fish**, use `~/.config/fish/config.fish`.

  Fish users can alternatively install a [plugin](https://github.com/chvolkmann/code-connect-fish-plugin) with the [fisher plugin manager](https://github.com/jorgebucaran/fisher).

  ```bash
  fisher install chvolkmann/code-connect-fish-plugin
  ```

## Changelog

See [CHANGELOG.md](./CHANGELOG.md)

## How it works

VS Code uses datagram sockets to communicate between a terminal and the rendering window.

The integrated terminal as well as the WSL terminal spawn an IPC socket. You also create one when manually attaching a remote SSH session. These sockets can be found in the folder VS Code Server.

Each time you connect remotely, the VS Code client instructs the server to fetch the newest version of itself. All versions are stored by commit id in `~/.vscode-server/bin`. `code-connect` uses the version that has been most recently accessed. The corresponding binary can be found in `~/.vscode-server/bin/<commid-id>/bin/code`.

A similar method is used to list all of VS Code's IPC sockets, which are located under `/run/user/<userid>/vscode-ipc-<UUID>.sock`, where `<userid>` is the [current user's UID](https://en.wikipedia.org/wiki/User_identifier) and `<UUID>` is a unique ID. VS Code does not seem to clean up all stale connections, so some of these sockets are active, some are not.

So the socket that is listening and that was accessed within a timeframe of 4 hours by default is chosen.

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

The script `code_connect.py` performs all of the above steps and runs the VS Code `code` executable
as a child process with `VSCODE_IPC_HOOK_CLI` set properly.

## [Contributing](./CONTRIBUTING.md)

- Fork the repo
- Commit your changes to your branch
- Create a pull request  
  _Please make sure that [edits to your pull request are permitted](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/allowing-changes-to-a-pull-request-branch-created-from-a-fork)._

## Credit

- Based on an [answer on StackOverflow](https://stackoverflow.com/a/60949722) by [stabledog](https://stackoverflow.com/users/237059/Stabledog)
