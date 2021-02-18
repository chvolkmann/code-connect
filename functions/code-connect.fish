#!/usr/bin/fish

# https://github.com/chvolkmann/code-connect

function code-connect --description 'Run Visual Studio Code through code-connect'
    # alias for code_connect.py
    ~/.code-connect/bin/code_connect.py $argv
end
