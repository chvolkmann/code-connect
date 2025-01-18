#!/usr/bin/env sh

# https://github.com/chvolkmann/code-connect

CODE_CONNECT_INSTALL_DIR=~/.code-connect


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
print_n() ( IFS=" " printf "$c_fg%s$c_reset" "$*" )
log() ( IFS=" " printf "$c_log%s$c_reset\n" "$*" )
error() ( IFS=" " printf "$c_err%s$c_reset\n" "$*" >&2 )


#####


alias_exists () {
    name="$1"
    grep -q "alias $name=*" ~/.bashrc
}

remove_alias () {
    name="$1"
    if alias_exists "$name"; then
        log "Removing alias ${c_emph}$name${c_log} from ${c_path}~/.bashrc"
        sed -i "/alias $name=/d" ~/.bashrc
    else
        log "Alias for ${c_emph}$name${c_log} not registered in ${c_path}~/.bashrc${c_log}, skipping"
    fi
    unalias "$name" > /dev/null 2>&1
}

remove_aliases () {
    print_n "May I modify your ${c_path}~/.bashrc${c_fg}? [yN] "
    read -r yn

    case $yn in
        [Yy]*)
            # Add the aliases to ~/.bashrc if not already done
            remove_alias "code"
            remove_alias "code-connect"

            ;;
        *)
            print "Okay; make sure to remove the following from your shell-profile manually:"
            print "alias code='...'"
            print "alias code-connect='...'"
            ;;
    esac

    printf \\n
}


#####

remove_aliases

log "Removing ${c_path}$CODE_CONNECT_INSTALL_DIR"
rm -rf $CODE_CONNECT_INSTALL_DIR

print ""
print "${c_emph}code-connect${c_fg} uninstalled successfully!"
