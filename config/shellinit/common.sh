#!/bin/sh

alias untar="tar -xaf"

clean_trailing_whitespace() {
    sed -i -E ':s;N;$!bs;s/\s+\n/\n/g' "$1"
}

select_dir() {
    local ifs_save="${IFS}"
    IFS=$'\n'
    # shellcheck disable=SC2046
    if ! local selected="$(gum choose $(find ./ -mindepth 1 -maxdepth 1 -name '[a-z]*' -type d -prune -printf '%P\n' | LC_ALL=C sort))"; then
        IFS="${ifs_save}"
        return 2
    fi
    IFS="${ifs_save}"

    printf "%s" "$selected"
}

poweroptions()
{
    if [ "$#" -eq 0 ]; then
        local selected="$(gum choose suspend reboot shutdown)";
        if [ -z "$selected" ]; then
            return 1
        fi
        poweroptions "$selected"
        return 0
    elif [ "$#" -gt 1 ]; then
        printf 'usage: %s [suspend|reboot|shutdown]\n' "$0" 1>&2
        return 1
    fi
    case "$1" in
        [Ss]uspend)
            systemctl suspend
            ;;
        [Rr]eboot)
            systemctl reboot
            ;;
        [Ss]hutdown)
            shutdown now
            ;;
        *)
            printf 'Not a valid power option %s\n' "$1" 1>&2
            return 1
            ;;
    esac
}

color()
{
    local err="$(printf "usage: %s <col_name|hex|reset>\nWhere col_name is one of: red, orange, yellow, lime, green, cyan, blue, purple, white, gray, or black, and hex is in the format #RRGGBB\n" "$0")"
    if [ $# -ne 1 ]; then
        printf "%s" "$err"
    fi

    case "$1" in
        (reset)
            printf "\x1b[0m"
            ;;
        ("#"*)
            local r="$(echo "ibase=16;$(echo "$1" | cut -c 2-3 | awk '{ print toupper($0) }')" | bc)"
            local g="$(echo "ibase=16;$(echo "$1" | cut -c 4-5 | awk '{ print toupper($0) }')" | bc)"
            local b="$(echo "ibase=16;$(echo "$1" | cut -c 6-7 | awk '{ print toupper($0) }')" | bc)"
            printf "\x1b[38;2;$r;$g;${b}m"
            ;;
        (*)
            printf "%s" "$err"
    esac
}

alias colour=color
