#!/bin/sh

export SHELL_CONFIG_PATH="$(dirname "$0")"
export SHELL_ACTIVE_NAME="UNKNOWN"
export SHELL_ACTIVE_PATH="UNKNOWN"

if ! [ -z "$ZSH_NAME" ]; then
    dev_log "Shell is zsh"
    export SHELL_ACTIVE_NAME="zsh"
    export SHELL_ACTIVE_PATH="$(where zsh)"
elif ! [ -z "$BASH" ]; then
    dev_log "Shell is bash"
    echo "Bash support is experimental. Expect issues"
    export SHELL_ACTIVE_NAME="bash"
    export SHELL_ACTIVE_PATH="$BASH"
else
    dev_log "UNKNOWN SHELL"
fi
