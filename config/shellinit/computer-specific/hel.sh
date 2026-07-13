#!/bin/sh

alias rstudio="nix-shell -p \"rstudioWrapper.override { packages = with rPackages; [ knitr readxl ggplot2 dplyr janitor rmarkdown ]; }\" --run \"rstudio\""

mount_afs()
{
    mkdir -p ~/afs
    sshfs -o reconnect luc.desmottes@ssh.cri.epita.fr:/afs/cri.epita.fr/user/l/lu/luc.desmottes/u/ ~/afs
    if [ $? -eq 0 ]; then
        return 1
    fi
    kinit -f luc.desmottes@CRI.EPITA.FR
    #sftp luc.desmottes@ssh.cri.epita.fr
    #cd /afs/cri.epita.fr/user/l/lu/luc.desmottes/u
    sshfs -o reconnect luc.desmottes@ssh.cri.epita.fr:/afs/cri.epita.fr/user/l/lu/luc.desmottes/u/ ~/afs
}
