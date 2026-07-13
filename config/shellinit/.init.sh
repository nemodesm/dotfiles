#!/bin/sh

source "$(dirname "$0")/debug.sh"

if [ -z "${WATCHER_PID}" ]; then
    source "$(dirname "$0")/01_variables.sh"
fi

case "$XDG_SESSION_TYPE" in
    x11)
        dev_log "Running graphics server (x11) scripts"
        source "${SHELL_CONFIG_PATH}/graphics-server/x11.sh"
        ;;
    *)
        dev_log "No graphics server ($XDG_SESSION_TYPE) scripts"
        ;;
esac

case "$XDG_CURRENT_DESKTOP" in
    Hyprland)
        dev_log "Running desktop environment (Hyprland) scripts"
        source "${SHELL_CONFIG_PATH}/desktop-specific/hyprland.sh"
        ;;
    *)
        dev_log "No desktop environment ($XDG_CURRENT_DESKTOP) scripts"
        ;;
esac

case "$(hostname)" in
    hel)
        dev_log "Running computer (hel) scripts"
        source "${SHELL_CONFIG_PATH}/computer-specific/hel.sh"
        ;;
    *.sm.cri.epita.fr)
        dev_log "Running computer (cri.epita.fr) scripts (matches *.sm.cri.epita.fr: $(hostname))"
        source "${SHELL_CONFIG_PATH}/computer-specific/cri.epita.fr.sh"
        ;;
    *)
        dev_log "No computer ($(hostname)) scripts"
        ;;
esac

case "$TERM" in
    *kitty)
        dev_log "Running terminal emulator (kitty) scripts"
        source "${SHELL_CONFIG_PATH}/term-emulator/kitty.sh"
        ;;
    *)
        dev_log "No terminal emulator ($TERM) scripts"
        ;;
esac

source "${SHELL_CONFIG_PATH}/theme.sh"
source "${SHELL_CONFIG_PATH}/common.sh"
source "${SHELL_CONFIG_PATH}/git.sh"
source "${SHELL_CONFIG_PATH}/steam.sh"
source "${SHELL_CONFIG_PATH}/qol.sh"
source "${SHELL_CONFIG_PATH}/nix.sh"
source "${SHELL_CONFIG_PATH}/program-wrappers.sh"

# setup file watcher
function __cleanup()
{
    if is_dev; then
        kill "${WATCHER_PID}" 2> ~/err_exit 1> ~/std_exit
    else
        kill "${WATCHER_PID}" 2> /dev/null 1> /dev/null
    fi
}

if [ -z "$WATCHER_RUNNING" ] && [ -z "$WATCHER_PID" ]; then
    dev_log "Started file watcher"
    trap "dev_log \"Reloaded config\"; source \"${SHELL_CONFIG_PATH}/.init.sh\"" USR1
    trap __cleanup EXIT

    set +m
    source "${SHELL_CONFIG_PATH}/watch.sh" 1>&2 2>/dev/null &
    WATCHER_PID=$!
    disown
    set -m
fi
