#!/bin/bash

_CODE_CONNECT_PY=$(realpath ~)/.code-connect/code_connect.py

echo "> Downloading code_connect.py from https://raw.githubusercontent.com/chvolkmann/code-connect/main/functions/code_connect.py"
mkdir -p $(dirname $_CODE_CONNECT_PY)
wget -q -O "$_CODE_CONNECT_PY" "https://raw.githubusercontent.com/chvolkmann/code-connect/main/functions/code_connect.py"
chmod +x "$_CODE_CONNECT_PY"

# Add the alias to ~/.bashrc if not already done
if [[ -z $(cat ~/.bashrc | grep "alias code=") ]]; then
    echo "> Alias added to ~/.bashrc"
    echo "alias code='$_CODE_CONNECT_PY'" >> ~/.bashrc
else
    echo "> code already aliased in ~/.bashrc, skipping"
fi

# Register the alias in the current shell
alias code="$_CODE_CONNECT_PY"

echo "> code-connect installed successfully!"
echo ">"
echo "> You can now use the code command, try it!"
