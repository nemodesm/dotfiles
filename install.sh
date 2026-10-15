#!/bin/env bash

set -e
set -u

is_dev()
{
    if [ "${DEBUG_ENV:-}" = "true" ]; then
        return 0
    fi
    return 1
}

echo "Installing dotfiles to '${DOTFILES_INSTALL_PATH:="$HOME/.dotfiles"}'"

# If detected to not have been invoked locally (e.g.: curl | bash)
if ! [ -f "$0" ]; then
    if is_dev; then
        echo "Would clone 'https://github.com/nemodesm/dotfiles.git' to '$DOTFILES_INSTALL_PATH'"
        exit 1
    fi

    git clone https://github.com/nemodesm/dotfiles.git "$DOTFILES_INSTALL_PATH"
    DOTFILES_INSTALL_PATH="$DOTFILES_INSTALL_PATH" "$DOTFILES_INSTALL_PATH/install.sh"
    exit $?
fi

script_dir=$(cd "$(dirname "$0")" && pwd)
pushd "$script_dir" >/dev/null

dotfiles="bashrc vimrc zshrc"
dotdirs="config"

# in the format program=package_name
# TODO: package names are given for arch linux, should work on getting the
# install script to work on other platforms
declare -A required_progs=([hostname]=inetutils [gum]=gum [bat]=bat [bc]=bc)

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

    if is_dev; then
        return
    fi

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
            echo "'$2' is already properly installed, skipping"
            return
        fi

        # not from a previous install, make a backup
        echo "'$2' already exists, moving existing version to '$2-$(date -I).bak'"
    
        if ! is_dev; then
            mv "$2" "${2}-$(date -I).bak"
        fi
    fi

    if is_dev; then
        echo "'$2' linked to, '$1'"
        return
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

if ! is_dev; then
    # generate initial neutral color scheme
    matugen color hex '#212121' -t scheme-neutral
fi

popd >/dev/null
