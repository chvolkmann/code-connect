#!/usr/bin/fish

# https://github.com/chvolkmann/code-connect

function code --description 'Run local code exectuable if installed, run code-connect otherwise'
    set -l local_code_executable (which code 2>/dev/null)
    if test -n "$local_code_executable"
        if not test -n "$SSH_CLIENT" && not test -n "$SSH_TTY"
            # code is in the PATH and we're not in an SSH session, use that binary instead of the code-connect
            $local_code_executable $argv
            return
        end
    end

    # code not locally installed, use code-connect
    code-connect $argv
end
