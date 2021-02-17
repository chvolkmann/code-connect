#!/bin/bash

# https://github.com/chvolkmann/code-connect

local_code_executable="$(which code)"
if test -n "$local_code_executable"; then
    # code is in the PATH, use that binary instead of the code-connect
    $local_code_executable $@
else
    # code not locally installed, use code-connect
    code-connect $@
fi
