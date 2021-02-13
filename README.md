# code-connect

Open a file in your locally running VS Code instance from any terminal.

## Motivation
VS Code supports opening files with the terminal using `code /path/to/file`. While this is possible in **WSL sessions** and **remote SSH sessions** if the integrated terminal is used, it is currently not possible for arbitrary terminals. Say, you have just SSH'd into a remote server using your favorite terminal and would like to open a webserver config file in your local VS Code instance.

You would have to get to VS Code, connect to your server through a remote session and find the file in VS Code's file browser.  
This utility enables you to call `code .` instead, just as you would in a WSL session.

## Installation
### VS Code Server
You need to set up VS Code Server before using this utility. For this, connect to your target in a remote SSH session.  
Afterwards, you should have a folder `.vscode-server` in your home directory.
### Shell Integration
#### Bash
Execute this and place it in your `.bashrc`
```bash
source init.sh
```
#### Fish
Execute this and place it in your `config.fish`
```fish
source init.fish
```


## Usage
First, run
```
code-connect
```
This will provide you with the `code` command from your server's VS Code Server installation. It also sets the environment variable `VSCODE_IPC_HOOK_CLI` to a valid IPC socket.

Then you're free to use
```
code /path/to/file
```

Note that you need to have an active instance of VS Code running.

## How it works
VS Code uses datagram sockets to communicate between a terminal and the rendering window.

The integrated terminal as well as the WSL terminal spawn an IPC socket. You also create one when manually attaching a remote SSH session. These sockets can be found in the folder VS Code Server.

Each time you connect remotely, the VS Code client instructs the server to fetch the newest version of itself. All versions are stored by commit id in `~/.vscode-server/bin`. `code-connect` uses the version that has been most recently accessed. The corresponding binary can be found in `~/.vscode-server/bin/<commid-id>/bin/code`.

A similar method is used to list all of VS Code's IPC sockets, which are located under `/run/user/1000/vscode-ipc-<UUID>.sock`, where `<UUID>` is a unique ID. VS Code does not seem to clean up all stale connections, so some of these sockets are active, some are not.

So the socket that is listening and that was accessed within a timeframe of 4 hours by default is chosen.

VS Code communicates the presence of an active IPC connection with the environment variable `VSCODE_IPC_HOOK_CLI` which stores the path to the socket.  
You can verify this by opening a connection to your remote machine. In one case, you use VS Code's integrated terminal. In the other case, you use any other terminal.

Run
```bash
echo $VSCODE_IPC_HOOK_CLI
```
which displays an output in the integrated terminal, but not on the other one.

In order, every socket is checked to see it is listening. For this, the following snippet based on [this answer on StackOverflow](https://unix.stackexchange.com/a/556790) was used.
```bash
socat -u OPEN:/dev/null UNIX-CONNECT:/path/to/socket
```
This returns `0` if and only if there's something listening.

The script `code_connect.py` does all of the above steps and outputs a string to stdout.

Sample output:
```bash
export VSCODE_IPC_HOOK_CLI="/run/user/1000/vscode-ipc-dd85cff3-04c7-4ca6-9c06-229acd73008c.sock"
alias code="/home/user/.vscode-server/bin/622cb03f7e070a9670c94bae1a45d78d7181fbd4/bin/code"
```

## Credit
- Based on an [answer on StackOverflow](https://stackoverflow.com/a/60949722) by [stabledog](https://stackoverflow.com/users/237059/Stabledog)