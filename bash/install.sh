#!/bin/bash

# https://github.com/chvolkmann/code-connect


# Configure this variable to change the install location of code-connect
CODE_CONNECT_INSTALL_DIR=~/.code-connect

CODE_CONNECT_BASE_URL="https://raw.githubusercontent.com/chvolkmann/code-connect/main"



cyan=`tput setaf 7`
red=`tput setaf 1`
magenta=`tput setaf 6`
grey=`tput setaf 8`
green=`tput setaf 10`
reset=`tput sgr0`

color_fg="$cyan"
color_log="$grey"
color_error="$red"
color_emph="$magenta"
color_file="$green"

print () {
    echo "$color_fg$@$reset"
}

log () {
    echo "$color_log$@$reset"
}

error () {
    echo "$color_error$@$reset"
}

c_emph () {
    echo -n "$color_emph$@$color_fg"
}

c_file () {
    echo -n "$color_file$@$color_fg"
}

l_emph () {
    echo -n "$color_emph$@$color_log"
}

l_file () {
    echo -n "$color_file$@$color_log"
}




download-repo-file () {
    repo_path="$1"
    output_path="$2"
    url="$CODE_CONNECT_BASE_URL/$repo_path"

    if test "$output_path" != "-"; then
        log "Downloading $(l_file $repo_path) from $(l_file $url)"
    fi

    data=$(curl -sS -o "$output_path" "$url")
    ret="$?"
    if test "$ret" != "0"; then
        error "Could not download $url: curl exited with status code $ret"
        error $data
        exit $ret
    fi
    echo -n $data
}

alias-exists () {
    name="$1"
    cat ~/.bashrc | grep -q "alias $name=*"
}

ensure-alias () {
    name="$1"
    val="$2"
    if alias-exists "$name"; then
        log "Alias $(l_emph $name) already registered in $(l_file '~/.bashrc'), skipping"
    else
        echo "alias $name='$val'" >> ~/.bashrc
        log "Adding alias $(l_emph $name) to $(l_file '~/.bashrc')"
    fi
}

version=$(download-repo-file "VERSION" -)
print ""
print "$(c_emph code-connect) ${color_log}v$version"
print ""

mkdir -p "$CODE_CONNECT_INSTALL_DIR/lib"

CODE_CONNECT_PY="$CODE_CONNECT_INSTALL_DIR/lib/code_connect.py"
download-repo-file "functions/code_connect.py" $CODE_CONNECT_PY
chmod +x "$CODE_CONNECT_PY"


mkdir -p "$CODE_CONNECT_INSTALL_DIR/bin"

CODE_SH="$CODE_CONNECT_INSTALL_DIR/bin/code.sh"
download-repo-file "bash/code.sh" $CODE_SH
chmod +x "$CODE_SH"

CODE_CONNECT_SH="$CODE_CONNECT_INSTALL_DIR/bin/code-connect.sh"
download-repo-file "bash/code-connect.sh" $CODE_CONNECT_SH
chmod +x "$CODE_CONNECT_SH"

print ""

# Add the aliases to ~/.bashrc if not already done
ensure-alias "code" "$CODE_SH"
ensure-alias "code-connect" "$CODE_CONNECT_SH"

print
print "$(c_emph code-connect) installed to $(c_file $CODE_CONNECT_INSTALL_DIR) successfully!"
print ""
print "Restart your shell or reload your $(c_file .bashrc) to see the changes."
print ""
print "  $(c_emph source) $(c_file '~/.bashrc')"
print ""

local_code_binary=$(which code)
if test -z "$local_code_binary"; then
    print "Local installation of $(c_emph code) detected at $(c_file $local_code_binary)"
    print "Use the $(c_emph code) executable as you would normally."
    print "If you want to connect to a remote VS Code session, use $(c_emph code-connect) as a drop-in replacement for $(c_emph code)!"
else
    print "Use the $(c_emph code) executable as you would normally and you will interface with an open VS Code remote session, if available."
    print "If you want to ${color_error}explicitly${color_fg} connect to a remote VS Code session, use $(c_emph code-connect) as a drop-in replacement for $(c_emph code)!"
fi
