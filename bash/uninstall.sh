#!/bin/bash

# https://github.com/chvolkmann/code-connect

CODE_CONNECT_INSTALL_DIR=$(realpath ~)/.code-connect



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


alias-exists () {
    name="$1"
    cat ~/.bashrc | grep -q "alias $name=*"
}

remove-alias () {
    name="$1"
    if alias-exists "$name"; then
        log "Removing alias $(l_emph $name) from $(l_file '~/.bashrc')"
        sed -i "/alias $name=/d" ~/.bashrc
    else
        log "Alias for $(l_emph $name) not registered in $(l_file '~/.bashrc'), skipping"
    fi
    unalias $name > /dev/null 2>&1
}

remove-alias "code"
remove-alias "code-connect"

log "Removing $(l_file $CODE_CONNECT_INSTALL_DIR)"
rm -rf $CODE_CONNECT_INSTALL_DIR

print ""
print "$(c_emph code-connect) uninstalled successfully!"
