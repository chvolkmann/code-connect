# Add the binary directory to user's path
PLUGIN_DIR="$(dirname $0)"
export PATH="${PATH}:${PLUGIN_DIR}/bin"

# update fpath, and then lazy autoload files in the directory as functions
fpath=($PLUGIN_DIR/zsh_functions $fpath)
autoload -U code code-connect
