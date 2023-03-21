#!/bin/bash

# https://github.com/chvolkmann/code-connect

# Use this script through an alias
#   alias code="/path/to/code.sh"

local_code_executable="$(which code 2>/dev/null)"
if [ -n "$local_code_executable" ] && ! ( [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] ); then
    # code is in the PATH and we're not in an SSH session, use that binary instead of the code-connect
    $local_code_executable $@
else
    # code not locally installed, use code-connect
    ~/.code-connect/bin/code_connect.py $@
fi
