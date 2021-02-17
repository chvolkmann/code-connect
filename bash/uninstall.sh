#!/bin/bash

# https://github.com/chvolkmann/code-connect

CODE_CONNECT_INSTALL_DIR=~/.code-connect


####

# Fancy output helpers

c_cyan=`tput setaf 7`
c_red=`tput setaf 1`
c_magenta=`tput setaf 6`
c_grey=`tput setaf 8`
c_green=`tput setaf 10`
c_reset=`tput sgr0`

c_fg="$c_cyan"
c_log="$c_grey"
c_err="$c_red"
c_emph="$c_magenta"
c_path="$c_green"

print () {
    echo "$c_fg$@$c_reset"
}

log () {
    echo "$c_log$@$c_reset"
}

error () {
    echo "$c_err$@$c_reset"
}


#####


alias-exists () {
    name="$1"
    cat ~/.bashrc | grep -q "alias $name=*"
}

remove-alias () {
    name="$1"
    if alias-exists "$name"; then
        log "Removing alias ${c_emph}$name${c_log} from ${c_path}~/.bashrc"
        sed -i "/alias $name=/d" ~/.bashrc
    else
        log "Alias for ${c_emph}$name${c_log} not registered in ${c_path}~/.bashrc${c_log}, skipping"
    fi
    unalias $name > /dev/null 2>&1
}


#####


remove-alias "code"
remove-alias "code-connect"

log "Removing ${c_path}$CODE_CONNECT_INSTALL_DIR"
rm -rf $CODE_CONNECT_INSTALL_DIR

print ""
print "${c_emph}code-connect${c_fg} uninstalled successfully!"
