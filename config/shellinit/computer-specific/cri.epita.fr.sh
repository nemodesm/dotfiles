#!/bin/bash

pacman()
{
    if [ $# -eq 0 ] || [ "$1" != "install" ] && [ "$1" != "i" ] && [ "$1" != "remove" ] && [ "$1" != "r" ]; then
        printf 'Usage: \n\t%s <install|i> [package [...]]\n\t%s <remove |r> [package [...]]\n' "$0" "$0" 1>&2
        return 1
    fi

    if [ "$1" = "install" ] || [ "$1" = "i" ]; then
        local nix_cmd="install"
    else
        # Do not add "e" for end of function `echo`
        local nix_cmd="remov"
    fi

    shift
    local -a chosen
    if [ $# -eq 0 ]; then
        if [ "$nix_cmd" = "install" ]; then
            echo "Fetching available packages"
            chosen="$(lspackages | fzf -m)"
        else
            chosen=$(cat "$AFS_DIR/.confs/session_proglist" | fzf -m)
        fi
    else
        chosen=("$@")
    fi

    # Unquoted chosen as packages do not have spaces
    for prog in "${chosen[@]}"; do
        if ! [ -z "$DEBUG_ENV" ]; then
            echo "running:" nix profile "$nix_cmd" "nixpkgs#$prog"
        else
            if [ "$nix_cmd" = "install" ]; then
                if ! nix profile "install" "nixpkgs#$prog"; then
                    echo "$prog" >> "$AFS_DIR/.confs/session_proglist"
                fi
            else
                if ! nix profile "remove" "$prog"; then
                    # FIXME: do closest match instead of exact
                    sed -i -E "/^$prog$/d" "$AFS_DIR/.confs/session_proglist"
                fi
            fi
        fi
    done

    echo "Successfully ${nix_cmd}ed packages. Use pac_persist to keep them on restart"
}

pac_persist()
{
    echo "Setting current program list as default"
    cp "$AFS_DIR/.confs/session_proglist" "$AFS_DIR/.confs/postinstall_proglist"
}

relog()
{
    kinit && aklog
}

# These are the various mice ids used at EPITA
xinput set-prop "PixArt Lenovo USB Optical Mouse" "libinput Natural Scrolling Enabled" 1 > /dev/null 2>&1
xinput set-prop "PixArt USB Optical Mouse" "libinput Natural Scrolling Enabled" 1 > /dev/null 2>&1
xinput set-prop "PixArt HP 125 USB Optical Mouse" "libinput Natural Scrolling Enabled" 1 > /dev/null 2>&1
xinput set-prop "Cherry USB Optical Mouse" "libinput Natural Scrolling Enabled" 1 > /dev/null 2>&1
xinput set-prop "Cherry USB Optical Mouse" "libinput AccelSpeed" "-1" > /dev/null 2>&1
