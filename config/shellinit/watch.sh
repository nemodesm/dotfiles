#!/bin/sh

if ! [ -z "$WATCHER_RUNNING" ]; then
    exit
fi

export WATCHER_RUNNING='true'

trap true USR1
# set -e

while true; do
    inotifywait -q -e modify,create,delete --include ".*\.sh" -r "$HOME/.config/shellinit" > /dev/null

    if [ $? -ne 0 ]; then
        dev_log "Shutdown file watcher"
        exit
    fi

    pkill "${SHELL_ACTIVE_NAME}" -SIGUSR1
done
