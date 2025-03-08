#!/bin/bash

# https://github.com/chvolkmann/code-connect

# Configure this variable to change the install location of code-connect
CODE_CONNECT_INSTALL_DIR=~/.code-connect
CODE_CONNECT_BASE_URL="https://raw.githubusercontent.com/chvolkmann/code-connect/main"

####

# Fancy output helpers

c_cyan=$(tput setaf 7)
c_red=$(tput setaf 1)
c_magenta=$(tput setaf 6)
c_grey=$(tput setaf 8)
c_green=$(tput setaf 10)
c_reset=$(tput sgr0)

c_fg="$c_cyan"
c_log="$c_grey"
c_err="$c_red"
c_emph="$c_magenta"
c_path="$c_green"

print() {
    echo "$c_fg$@$c_reset"
}

log() {
    echo "$c_log$@$c_reset"
}

error() {
    echo "$c_err$@$c_reset"
}

# Helpers

download-repo-file() {
    repo_path="$1"
    output_path="$2"
    url="$CODE_CONNECT_BASE_URL/$repo_path"

    if test "$output_path" != "-"; then
        log "Downloading ${c_path}$repo_path${c_log} from ${c_path}$url"
    fi

    curl -sS -o "$output_path" "$url"
    ret="$?"
    if test "$ret" != "0"; then
        error "ERROR: Could not fetch ${c_path}$url${c_err}"
        error "${c_emph}curl${c_err} exited with status code ${c_emph}$ret"
        exit $ret
    fi
}

alias-exists() {
    name="$1"
    cat ~/.bashrc | grep -q "alias $name=*"
}

ensure-alias() {
    name="$1"
    val="$2"
    if alias-exists "$name"; then
        log "Alias ${c_emph}$name${c_log} already registered in ${c_path}~/.bashrc${c_log}, skipping"
    else
        echo "alias $name='$val'" >>~/.bashrc
        log "Adding alias ${c_emph}$name${c_log} to ${c_path}~/.bashrc"
    fi
}

#####

version=$(download-repo-file "VERSION" -)
print ""
print "${c_emph}code-connect ${c_log}v$version"
print ""

# Download the required files from the repository

mkdir -p "$CODE_CONNECT_INSTALL_DIR/bin"

CODE_CONNECT_PY="$CODE_CONNECT_INSTALL_DIR/bin/code_connect.py"
download-repo-file "bin/code_connect.py" $CODE_CONNECT_PY
chmod +x "$CODE_CONNECT_PY"

mkdir -p "$CODE_CONNECT_INSTALL_DIR/bash"

CODE_SH="$CODE_CONNECT_INSTALL_DIR/bash/code.sh"
download-repo-file "bash/code.sh" $CODE_SH
chmod +x "$CODE_SH"

CODE_CONNECT_SH="$CODE_CONNECT_INSTALL_DIR/bash/code-connect.sh"
download-repo-file "bash/code-connect.sh" $CODE_CONNECT_SH
chmod +x "$CODE_CONNECT_SH"

print ""

# Add the aliases to ~/.bashrc if not already done
ensure-alias "code" "$CODE_SH"
ensure-alias "code-connect" "$CODE_CONNECT_SH"

print ""
print "${c_emph}code-connect${c_fg} installed to ${c_path}$CODE_CONNECT_INSTALL_DIR${c_fg} successfully!"
print ""
print "Restart your shell or reload your ${c_path}.bashrc${c_fg} to see the changes."
print ""
print "  ${c_emph}source ${c_path}.bashrc"
print ""

local_code_binary=$(which code)
if test -z "$local_code_binary"; then
    print "Local installation of ${c_emph}code${c_fg} detected at ${c_path}$local_code_binary"
    print "Use the ${c_emph}code${c_fg} executable as you would normally."
    print "If you want to connect to a remote VS Code session, use ${c_emph}code-connect${c_fg} as a drop-in replacement for ${c_emph}code${c_fg}!"
else
    print "Use the ${c_emph}code${c_fg} executable as you would normally and you will interface with an open VS Code remote session, if available."
    print "If you want to ${c_err}explicitly${c_fg} connect to a remote VS Code session, use ${c_emph}code-connect${c_fg} as a drop-in replacement for ${c_emph}code${c_fg}!"
fi
