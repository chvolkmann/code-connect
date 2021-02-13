_CODE_CONNECT_DIR=$(dirname $0)

cyan=`tput setaf 7`
red=`tput setaf 1`
magenta=`tput setaf 6`
reset=`tput sgr0`

code-connect () {
    result=$($_CODE_CONNECT_DIR/code_connect.py)

    ret="$?"
    if [[ "$ret" -ne 0 ]]; then
        echo "${red}Discovery of VS Code instance failed.${reset}"
        exit 1
    fi

    eval "$result"

    ret="$?"
    if [[ "$ret" -ne 0 ]]; then
        echo "${red}Discovery of VS Code instance failed.${reset}"
        exit 1
    fi
    
    echo "${cyan}You can now use ${magenta}code${cyan}, try it!"
    echo ""
    echo "  ${magenta}code .${reset}"
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
    echo "${magenta}code-connect ${cyan}deactivated.${reset}"
}

echo "${cyan}Connect to this machine with a VS Code Remote SSH session once."
echo ""
echo "Afterwards, run"
echo ""
echo "  ${magenta}code-connect"
echo ""
echo "${cyan}and the code CLI command should be available to you.${reset}"