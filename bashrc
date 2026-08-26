PS1='\[\e[32;1m\][\[\e[36m\]\u\[\e[0;32m\]@\[\e[36;1m\]\h\[\e[0m\] \[\e[37;1m\]\W\[\e[32m\]]\[\e[91m\]\$\[\e[0m\] '
#PS1="\\[\\e[32;1m\\][\\[\\e[36m\\]\\u\\[\\e[0;32m\\]@\\[\\e[36;1m\\]\\h\\[\\e[0m\\] \\[\\e[37;1m\\]\\W\\[\\e[32m\\]]\\[\\e[9${SHLVL}m\\]\\\$\\[\\e[0m\\] "

source ~/.config/shellinit/.init.sh
#source ~/.shrc

header() {
    if ! [ -f "${1,,}.h" ]; then
        echo "#ifndef ${1^^}_H\n#define ${1^^}_H\n\n\n\n#endif /* ! ${1^^}_H */" > "${1,,}.h"
    fi
    vim "${1,,}.h"
}

alias reload="source ~/.bashrc"

return
'''




return
