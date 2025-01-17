#!/usr/bin/env sh

# https://github.com/chvolkmann/code-connect

# Configure this variable to change the install location of code-connect
CODE_CONNECT_INSTALL_DIR=~/.code-connect

CODE_CONNECT_BASE_URL="https://raw.githubusercontent.com/chvolkmann/code-connect/main"


####

# Fancy output helpers

c_cyan="$(tput setaf 7)"
c_red="$(tput setaf 1)"
c_magenta="$(tput setaf 6)"
c_grey="$(tput setaf 8)"
c_green="$(tput setaf 10)"
c_reset="$(tput sgr0)"

c_fg="$c_cyan"
c_log="$c_grey"
c_err="$c_red"
c_emph="$c_magenta"
c_path="$c_green"

print() ( IFS=" " printf "$c_fg%s$c_reset\n" "$*" )
log() ( IFS=" " printf "$c_log%s$c_reset\n" "$*" )
error() ( IFS=" " printf "$c_err%s$c_reset\n" "$*" >&2 )


# Helpers

download_repo_file () {
    repo_path="$1"
    output_path="$2"
    url="$CODE_CONNECT_BASE_URL/$repo_path"

    if test "$output_path" != "-"; then
        log "Downloading ${c_path}$repo_path${c_log} from ${c_path}$url"
    fi

    curl -sSL -o "$output_path" "$url"
    ret="$?"
    if test "$ret" != "0"; then
        error "ERROR: Could not fetch ${c_path}$url${c_err}"
        error "${c_emph}curl${c_err} exited with status code ${c_emph}$ret"
        exit $ret
    fi
}

alias_exists () {
    name="$1"
    grep -q "alias $name=*" ~/.bashrc
}

ensure_alias () {
    name="$1"
    val="$2"
    if alias_exists "$name"; then
        log "Alias ${c_emph}$name${c_log} already registered in ${c_path}~/.bashrc${c_log}, skipping"
    else
        echo "alias $name='$val'" >> ~/.bashrc
        log "Adding alias ${c_emph}$name${c_log} to ${c_path}~/.bashrc"
    fi
}


#####


version=$(download_repo_file "VERSION" -)
printf \\n
print "${c_emph}code-connect ${c_log}v$version"
printf \\n


# Download the required files from the repository

mkdir -p "$CODE_CONNECT_INSTALL_DIR/bin"

CODE_CONNECT_PY="$CODE_CONNECT_INSTALL_DIR/bin/code_connect.py"
download_repo_file "bin/code_connect.py" $CODE_CONNECT_PY
chmod +x "$CODE_CONNECT_PY"

mkdir -p "$CODE_CONNECT_INSTALL_DIR/bash"

CODE_SH="$CODE_CONNECT_INSTALL_DIR/bash/code.sh"
download_repo_file "bash/code.sh" $CODE_SH
chmod +x "$CODE_SH"

CODE_CONNECT_SH="$CODE_CONNECT_INSTALL_DIR/bash/code-connect.sh"
download_repo_file "bash/code-connect.sh" $CODE_CONNECT_SH
chmod +x "$CODE_CONNECT_SH"

printf \\n


# Add the aliases to ~/.bashrc if not already done
ensure_alias "code" "$CODE_SH"
ensure_alias "code-connect" "$CODE_CONNECT_SH"


printf \\n
print "${c_emph}code-connect${c_fg} installed to ${c_path}$CODE_CONNECT_INSTALL_DIR${c_fg} successfully!"
printf \\n
print "Restart your shell or reload your ${c_path}.bashrc${c_fg} to see the changes."
printf \\n
print "  ${c_emph}source ${c_path}.bashrc"
printf \\n


local_code_binary="$(which code)"
if test -z "$local_code_binary"; then
    print "Local installation of ${c_emph}code${c_fg} detected at ${c_path}$local_code_binary"
    print "Use the ${c_emph}code${c_fg} executable as you would normally."
    print "If you want to connect to a remote VS Code session, use ${c_emph}code-connect${c_fg} as a drop-in replacement for ${c_emph}code${c_fg}!"
else
    print "Use the ${c_emph}code${c_fg} executable as you would normally and you will interface with an open VS Code remote session, if available."
    print "If you want to ${c_err}explicitly${c_fg} connect to a remote VS Code session, use ${c_emph}code-connect${c_fg} as a drop-in replacement for ${c_emph}code${c_fg}!"
fi
