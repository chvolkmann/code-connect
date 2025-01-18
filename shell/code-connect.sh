#!/usr/bin/env sh

# https://github.com/chvolkmann/code-connect

# Use this script through an alias
#   alias code-connect="/path/to/code-connect.sh"

code_connect_dir=$(CDPATH='' cd -- "$(dirname -- "$(dirname -- "$0")")" && pwd)
"$code_connect_dir/bin/code_connect.py" "$@"
