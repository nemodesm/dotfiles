#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Save command history
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=10000

autoload -Uz compinit
compinit

PROMPT="%B%F{green}[%F{cyan}%n%b%F{green}@%B%F{cyan}%m%f %2~%F{green}]%F{red}$%f%b "

bindkey "\e[3~" delete-char

source ~/.config/shellinit/.init.sh
[ -s "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
[ -s "$HOME/.shrc.local" ] && source "$HOME/.shrc.local"

header() {
    if ! [ -f "${1:l}.h" ]; then
        echo "#ifndef ${1:u}_H\n#define ${1:u}_H\n\n\n\n#endif /* ! ${1:u}_H */" > "${1:l}.h"
    fi
    vim "${1:l}.h"
}

alias reload="source ~/.zshrc"

return
'''
return
