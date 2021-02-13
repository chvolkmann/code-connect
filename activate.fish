# set HERE (dirname (status --current-filename))
# alias code-connect="$HERE/code_connect.py | source && echo Connection to VS Code established successfully!"

set _CODE_CONNECT_DIR (dirname (status --current-filename))

set cyan (tput setaf 7)
set red (tput setaf 1)
set magenta (tput setaf 6)
set reset (tput sgr0)

function code-connect
    $_CODE_CONNECT_DIR/code_connect.py | source
    if test $status -ne 0
        echo -n $red
        echo "Discovery of VS Code instance failed."
        echo -n $reset
        return 2
    end

    echo -n $cyan
    echo "You can now use $magenta code $cyan, try it!"
    echo ""
    echo -n $magenta
    echo "  code ."
    echo -n $reset
end

function code-disconnect
    set -e VSCODE_IPC_HOOK_CLI
    functions -e code
end

function deactivate
    code-disconnect
    set -e _CODE_CONNECT_DIR
    functions -e code-connect
    functions -e code-disconnect
    functions -e deactivate
    echo -n $magenta
    echo -n "code-connect"
    echo "$cyan deactivated $reset"
end

echo -n $cyan
echo "Connect to this machine with a VS Code Remote SSH session once."
echo ""
echo "Afterwards, run"
echo ""
echo -n $magenta
echo "  code-connect"
echo ""
echo -n $cyan
echo "and the code CLI command should be available to you"
echo -n $reset
