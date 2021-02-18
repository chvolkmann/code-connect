#!/usr/bin/fish

# https://github.com/chvolkmann/code-connect

function code-connect --description 'Run Visual Studio Code through code-connect'
    # absolute path to code_connect.py
    set -l _CODE_CONNECT_PY (dirname (realpath (status --current-filename)))/code_connect.py

    $_CODE_CONNECT_PY $argv
end
