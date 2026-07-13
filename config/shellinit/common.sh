#!/bin/sh

alias untar="tar -xaf"

clean_trailing_whitespace() {
    sed -i -E ':s;N;$!bs;s/\s+\n/\n/g' "$1"
}

select_dir() {
    ifs_save="${IFS}"
    IFS="
"
    # shellcheck disable=SC2046
    if ! selected="$(gum choose $(find ./ -mindepth 1 -maxdepth 1 -name '[a-z]*' -type d -prune -printf '%P\n' | LC_ALL=C sort))"; then
        IFS="${ifs_save}"
        return 2
    fi
    IFS="${ifs_save}"

    printf "%s" "$selected"
}
