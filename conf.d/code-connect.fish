#!/usr/bin/fish

# https://github.com/chvolkmann/code-connect

function _on_code-connect_install --on-event code-connect_install
    mkdir -p ~/.code-connect/bin
    curl -sS "https://raw.githubusercontent.com/chvolkmann/code-connect/next/bin/code_connect.py" >~/.code-connect/bin/code_connect.py
    chmod +x ~/.code-connect/bin/code_connect.py
end

function _on_code-connect_update --on-event code-connect_update
    _on_code-connect_install
end

function _on_code-connect_uninstall --on-event code-connect_uninstall
    rm -rf ~/.code-connect
end
