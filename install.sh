#!/bin/sh

script_dir=$(cd "$(dirname "$0")" && pwd)
pushd "$script_dir" >/dev/null

dotfiles="bashrc vimrc zshrc"

for file in $dotfiles; do
    # echo "$file"
    rm -rf "$HOME/.$file"
    ln -s "${script_dir}/$file" "$HOME/.$file"
done

dirs="config"

for dir in $dirs; do
    for item in $dir/*; do
        # echo "$item"
        rm -rf "$HOME/.$dir/$item"
        ln -s "${script_dir}/$dir/$item" "$HOME/.$dir/$item"
    done
done

popd >/dev/null
