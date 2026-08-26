#!/bin/env bash

set -e
set -u

echo "Installing dotfiles to '${DOTFILES_INSTALL_PATH:="$HOME/.dotfiles"}'"

# If detected to not have been invoked locally (e.g.: curl | bash)
if ! [ -f "$0" ]; then
    git clone git@github.com:nemodesm/dotfiles.git "$DOTFILES_INSTALL_PATH"
    "$DOTFILES_INSTALL_PATH/install.sh"
    exit $?
fi

script_dir=$(cd "$(dirname "$0")" && pwd)
pushd "$script_dir" >/dev/null

dotfiles="bashrc vimrc zshrc"
dotdirs="config"

# in the format program=package_name
declare -A required_progs=([hostname]=inetutils [gum]=gum)

is_prog_installed()
{
    if ! command -v "$1" >/dev/null 2>&1; then
        return 1
    fi

    return 0
}

install_prog()
{
    echo "Installing package '$1'"
    case "$(lsb_release -si)" in
        ("Arch")
            sudo pacman -S "$1"
            ;;
    esac
}

ln_safe()
{
    # $1 from
    # $2 to
    if [ $# -ne 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
        printf "usage: %s <from> <to>\n" "$0" 1>&2
        return 1
    fi

    if [ -e "$2" ]; then
        if [ "$(readlink -f "$2")" = "$1" ]; then
            # echo "'$2' is already properly installed, skipping"
            return
        fi

        # not from a previous install, make a backup
        echo "'$2' already exists, moving existing version to '$2-$(date -I).bak'"
        mv "$2" "${2}-$(date -I).bak"
    fi

    ln -s "$1" "$2"
}

for file in $dotfiles; do
    ln_safe "${script_dir}/$file" "$HOME/.$file"
done

for dir in $dotdirs; do
    for item in "$dir"/*; do
        ln_safe "${script_dir}/$item" "$HOME/.$item"
    done
done

for exe in "${!required_progs[@]}"
do
    if ! command -v "$exe" >/dev/null 2>&1; then
        install_prog "${required_progs[$exe]}"
    fi
done

popd >/dev/null
