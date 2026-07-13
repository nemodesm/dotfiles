autoload -Uz compinit
compinit

PROMPT="%B%F{green}[%F{cyan}%n%b%F{green}@%B%F{cyan}%m%f %2~%F{green}]%F{red}$%f%b "
# PROMPT="%B%F{green}[%f%F{cyan}%n%f%b%F{green}@%f%B%F{cyan}%m%f %2~%F{green}]%f%F{red}$%f%b "
# RPROMPT="%?"

bindkey "\e[3~" delete-char

source ~/.config/shellinit/.init.sh
# source ~/.shrc

header() {
    if ! [ -f "${1:l}.h" ]; then
        echo "#ifndef ${1:u}_H\n#define ${1:u}_H\n\n\n\n#endif /* ! ${1:u}_H */" > "${1:l}.h"
    fi
    vim "${1:l}.h"
}

alias reload="source ~/.zshrc"
export PGDATA="$HOME/postgres_data"
export PGHOST="/tmp"
export PGPORT="5432"

start_wallpaper()
{
    hyprpaper &
    /home/nemodesm/programs/walltaker-client/walltaker.sh &
}

return
'''




return
