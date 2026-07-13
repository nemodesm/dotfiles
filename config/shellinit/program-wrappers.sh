#!/bin/sh

discordo()
{
    if [ -f ~/discordo/discordo ]; then
        ~/discordo/discordo
    else
        local script="$(mktemp)"
        echo 'git clone https://github.com/ayn2op/discordo ~/discordo' > "${script}"
        echo 'cd ~/discordo' >> "${script}"
        echo 'nix-shell -p go xorg.libX11 --run "go build ."' >> "${script}"
        echo 'cd -' >> "${script}"
        gum spin --title "Building source" -- bash ${script}
        rm ${script}
        discordo
    fi
}
