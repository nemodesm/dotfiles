#!/bin/sh

# === Better visuals ===
alias cat="bat -p"
alias grep='grep --color -n'
alias ls="ls --color=auto"

# === Shorthands ===
alias nv="nvim"

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

where() {
    builtin where "$@" | bat -pPl sh
}
