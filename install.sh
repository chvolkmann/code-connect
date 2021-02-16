#!/bin/bash

# Fetch code_connect.py
mkdir -p ~/.code-connect
wget https://raw.githubusercontent.com/chvolkmann/code-connect/main/functions/code_connect.py

# Add the alias to ~/.bashrc if not already done
if [[ -z $(cat ~/.bashrc | grep "alias codes=") ]]; then
    echo 'alias code="/path/to/code_connect.py"' >> ~/.bashrc
fi

# Register the alias in the current shell
alias code="/path/to/code_connect.py"
