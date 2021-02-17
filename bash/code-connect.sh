#!/bin/bash

# https://github.com/chvolkmann/code-connect

# Use this script through an alias
#   alias code-connect="/path/to/code-connect.sh"

_CODE_CONNECT_PY="$(dirname \"$0\")"/code_connect.py
$_CODE_CONNECT_PY $@
