#!/usr/bin/fish

# https://github.com/chvolkmann/code-connect

# absolute path to code_connect.py
set _CODE_CONNECT_PY (dirname (realpath (status --current-filename)))/code_connect.py

function code --description 'Run Visual Studio Code through code-connect'
    $_CODE_CONNECT_PY $argv
end