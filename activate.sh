_CODE_CONNECT_DIR=$(dirname $0)
code-connect () {
    result=$($_CODE_CONNECT_DIR/code_connect.py)

    ret="$?"
    if [[ "$ret" -ne 0 ]]; then
        echo "Discovery of VS Code instance failed."
        exit 1
    fi

    eval "$result"

    ret="$?"
    if [[ "$ret" -ne 0 ]]; then
        echo "Discovery of VS Code instance failed."
        exit 1
    fi
    echo "You can now use code, try it!"
    echo ""
    echo "  code ."
}
code-disconnect () {
    unset VSCODE_IPC_HOOK_CLI
    unalias code
}
deactivate () {
    code-disconnect
    unset _CODE_CONNECT_DIR
    unset -f code-connect
    unset -f code-disconnect
    unset -f deactivate
    echo "code-connect deactivated"
}

echo "Connect to this machine with a VS Code Remote SSH session once."
echo ""
echo "Afterwards, run"
echo ""
echo "  code-connect"
echo ""
echo "and the code CLI command should be available to you."