#!/bin/sh

function change_theme()
{
    # TODO
    echo "Changing themes is not yet implemented" 1>&2
    return 1
}

matugen()
{
    if [ $# -eq 0 ]; then
        local col="$(gum choose "$(color "#007795")#007795" "$(color "#b0503f")#b0503f")"
        if ! [ -z "$col" ]; then
            matugen color hex "$col"
        fi
    else
        command matugen "$@"
    fi
}

source "${SHELL_CONFIG_PATH}/theme/gum.sh"
