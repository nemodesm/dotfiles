#!/bin/sh

pacman()
{
    if [ $# -eq 0 ] || [ "$1" != "install" -a "$1" != "i" -a "$1" != "remove" -a "$1" != "r" ]; then
        printf 'Usage: \n\t%s <install|i> [package [...]]\n\t%s <remove |r> [package [...]]\n' "$0" "$0" 1>&2
        return 1
    fi

    if [ "$1" = "install" -o "$1" = "i" ]; then
        nix_cmd="install"
    else
        # Do not add "e" for end of function `echo`
        nix_cmd="remov"
    fi

    shift
    if [ $# -eq 0 ]; then
        if [ "$nix_cmd" = "install" ]; then
            echo "Fetching available packages"
            chosen="$(lspackages | gum filter --no-limit)"
        else
            chosen="$(cat "$AFS_DIR/.confs/session_proglist" | gum filter --no-limit)"
        fi
    else
        chosen="$@"
    fi

    # Unquoted chosen as packages do not have spaces
    for prog in $chosen; do
        if ! [ -z "$DEBUG_ENV" ]; then
            echo "running:" nix profile "$nix_cmd" "nixpkgs#$prog"
        else
            if [ "$nix_cmd" = "install" ]; then
                nix profile "install" "nixpkgs#$prog"
                if [ $? -eq 0 ]; then
                    echo "$prog" >> "$AFS_DIR/.confs/session_proglist"
                fi
            else
                nix profile "remove" "$prog"
                if [ $? -eq 0 ]; then
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
