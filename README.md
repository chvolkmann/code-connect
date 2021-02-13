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

## Under the Hood
TBD

## Credit
- Based on an [answer on StackOverflow](https://stackoverflow.com/a/60949722) by [stabledog](https://stackoverflow.com/users/237059/Stabledog)