#!/bin/sh

# === Better visuals ===
alias cat="bat -p"
alias grep='grep --color -n'
alias ls="ls --color=auto"

# === Platform Agnostic
alias edit="vim"

# === Backup originals ===
alias ccat="command cat"
alias treee="command tree"

# === Simpler names ===
alias untar="tar -xf"

relog()
{
    kinit && aklog
}

tree()
{
    command tree "$@" -I ".git" | bat -p
}

# TODO: should this be in git.sh?
git() {
    if [ $# -eq 0 ]; then
        command git
        return $?
    fi

    case "$1" in
        *)
            command git "$@"
    esac
}

where() {
    builtin where "$@" | bat -pPl sh
}
