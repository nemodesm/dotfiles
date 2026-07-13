#!/bin/sh

if [ -z "$(command -v nix)" ]; then
    exit
fi

lspackages()
{
    if [ $# -gt 1 ]; then
        printf "Usage: %s [-i | --installed]\n" "$0" 1>&2
        return 1
    fi

    if [ $# -ne 0 ] && [ "$1" = "-i" -o "$1" = "--installed" ]; then
        nix profile list --json | python -m json.tool | command grep -E "^        \"" | sed -E 's/[^"]*"([a-zA-Z_-]*)": \{/\1/' | sort -u
    else
        nix search nixpkgs '' --json | python -m json.tool | command grep -E "^    \"" | sed -E 's/[^"]*\"(legacyPackages.x86_64-linux.)?([^"]*)": \{/\2/' | sort -u
    fi
}

shell()
{
    nix-shell -p "$@" --run "$SHELL_ACTIVE_PATH"
}

pinstall()
{
    nix profile install nixpkgs#$@
}
