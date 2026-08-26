#!/bin/sh

# alias s='git status'
# alias a='fmt *.c && git add .'
# alias ga="git add ."
# alias c='git commit -m'
# alias t='git tag -ma'
# alias p='git push'
# alias pt='git push --follow-tags'

git()
{
    if [ $# -eq 0 ]; then
        command git
        return $?
    fi

    case "$1" in
        "switch")
            if [ $# -eq 1 ]; then
                branches=$(command git for-each-ref --format='%(refname:short)' refs/heads refs/remotes | sed 's|^origin/||' | sort -u)

                to_branch="$(gum choose <<< "$branches")"

                if [ $? -ne 0 ]; then
                    return 1
                fi

                command git switch "$to_branch"
                return $?
            else
                shift
                command git switch "$@"
                return $?
            fi
            ;;
        "commit")
            if [ $# -eq 1 ]; then
                message="$(gum input --placeholder "Commit message")"
                if [ $? -ne 0 ]; then
                    return 1
                fi

                if gum confirm --default=0 "Write description?"; then
                    desc="$(gum write --placeholder "Description...")"
                    if [ $? -ne 0 ]; then
                        return 1
                    fi

                    command git commit -m "$message" -m "$desc"
                    return $?
                else
                    command git commit -m "$message"
                    return $?
                fi
            else
                shift
                command git commit "$@"
                return $?
            fi
            ;;
        "log")
            if [ $# -eq 1 ]; then
                command git log --graph
                return $?
            else
                shift
                command git log "$@"
                return $?
            fi
            ;;
        *) 
            command git "$@"
            return $?
            ;;
    esac
}

cc()
{
    # == Check gitignore ==
    if ! [ -f .gitignore ] || ! cat .gitignore | grep -q ".gittagcount" || ! cat .gitignore | grep -q ".gittagprefix" || ! cat .gitignore | grep -q ".gitdelayedtag"; then
        if gum confirm "It seems you have not ignored '.gittagcount', '.gittagprefix', and '.gitdelayedtag', do you want to add them to your .gitignore"; then
            {
                echo ""
                echo "# Autogit (cc) ignores"
                echo ".gittagcount"
                echo ".gittagprefix"
                echo ".gitdelayedtag"
            } >> .gitignore
        fi
    fi

    if [ -z "$1" ]; then
        local exer="$(select_dir)"
        if [ -z "$exer" ]; then
            return 2
        fi
        local directory="$exer"
    else
        local directory="$1"
        if [ "$directory" = "." ]; then
            local exer="$(gum input --header "\"exer\" name (used for tags)")"
            if [ -z "$exer" ]; then
                return 2
            fi
        else
            local exer="$1"
        fi
    fi

    # == Add ==
    if is_dev; then
        echo "added $directory"
    else
        git add "$directory"
    fi

    if [ $? -ne 0 ]; then
        printf "Error on add\n" 1>&2
        return 1
    fi

    # == Commit ==

    # Find subject
    local subject_path="$exer/subject.pdf"
    if ! [ -f "$subject_path" ]; then
        local subject_path="$exer/$exer.pdf"
    fi
    if ! [ -f "$subject_path" ]; then
        local subject_path="$exer.pdf"
    fi
    if ! [ -f "$subject_path" ]; then
        printf "subject not found... using manual name\n" 1>&2
        local subject_path=""
    fi

    local tmpfile="$(mktemp)"

    if is_dev; then
        echo "commiting"
    else
        if [ -z "$subject_path" ]; then
            gum spin --spinner dot --title "Commiting" -- git commit -m "$(gum input --placeholder "Commit message" --value "$exer")" > "$tmpfile"
        else
            gum spin --spinner dot --title "Commiting" -- git commit -m "$(cat "$subject_path")" > "$tmpfile"
        fi
    fi

    if [ $? -ne 0 ]; then
        printf "Error on commit:\n" 1>&2
        cat "$tmpfile" 1>&2
        if is_dev; then
            echo "restored ."
        else
            git restore --staged .
        fi
        return 1
    fi

    # == Tag ==

    local tagged="false"
    if gum confirm "Tag?"; then
        __local_tagAuto()
        {
            local directory="$1"
            local exer="$2"
            if ! [ -f "$directory/.gittagcount" ]; then
                echo 0 > "$directory/.gittagcount"
            fi

            local count=$(cat "$directory/.gittagcount")
            local count=$((count + 1))
            echo "$count" > "$directory/.gittagcount"

            if [ -f "$directory/.gittagprefix" ]; then
                local tag_name="$(cat "$directory/.gittagprefix")-$exer-$(printf %04d "$(echo "obase=2;$count" | bc)")"
            elif [ -f ".gittagprefix" ]; then
                local tag_name="$(cat ".gittagprefix")-$exer-$(printf %04d "$(echo "obase=2;$count" | bc)")"
            else
                local tag_name="$exer-$(printf %04d "$(echo "obase=2;$count" | bc)")"
            fi

            echo "$tag_name"
        }

        local tagged="true"
        local var_tag_mode="$(gum choose "Auto Tag" "Auto Tag (change tag prefix)" "Manual Tag")"
        case "${var_tag_mode}" in
            "Auto Tag (change tag prefix)")
                if [ -f "$directory/.gittagprefix" ]; then
                    local var_tag_prefix="$(cat "$directory/.gittagprefix")"
                fi
                local var_tag_prefix="$(gum input --width 25 --placeholder "Tag prefix" --value "$var_tag_prefix")"
                if [ -z "$var_tag_prefix" ]; then
                    rm -f "$directory/.gittagprefix"
                else
                    echo "$var_tag_prefix" > "$directory/.gittagprefix"
                fi

                local tag_name="$(__local_tagAuto "$directory" "$exer")"
                ;;

            "Auto Tag")
                local tag_name="$(__local_tagAuto "$directory" "$exer")"
                ;;

            "Manual Tag")
                tag_name="$(gum input --width 25 --placeholder "Tag name")"
                ;;
            *)
                unfunction __local_tagAuto
                printf 'Invalid case value\n' 1>&2
                return 99
                ;;
        esac

        unfunction __local_tagAuto
    fi

    # == Push ==
    if [ "$tagged" = "true" ]; then
        local push_when="$(gum choose "Push" "Schedule push" "Do not push")"
        case "${push_when}" in
            "Push")
                if is_dev; then
                    echo "tagged with $tag_name"
                else
                    git tag -ma "$tag_name"
                fi

                if [ $? -ne 0 ]; then
                    printf "Error on tag\n" 1>&2
                    return 1
                fi

                local script="$(mktemp)"

                if is_dev; then
                    echo "pushed"
                else
                    echo 'git push -q --follow-tags >/dev/null 2>/dev/null' > "$script"
                    gum spin --spinner dot --title "Pushing" -- bash "$script" > /dev/null
                    if [ $? -ne 0 ]; then
                        rm "$script"
                        printf "Error on push\n" 1>&2
                        return 1
                    fi
                    rm "$script"
                fi
                ;;

            "Schedule push")
                if [ -f "$directory/.gitdelayedtag" ]; then
                    if gum confirm "It seems there is an already a delayed tag... Cancel it?"; then
                        # Kinda security flaw but if you really want to mess
                        # this up, it's your repo
                        if ! kill -9 "$(cat "$directory/.gitdelayedtag")"; then
                            printf "Error trying to kill scheduled tag. Was saved as process %s\n" "$(cat "$directory/.gitdelayedtag")" 1>&2
                        fi
                        rm "$directory/.gitdelayedtag"
                    else
                        return 6
                    fi
                fi

                local delay="$(gum input --width 3 --placeholder "Time in minutes")"
                if is_dev; then
                    echo "pushed without tag"
                else
                    echo 'git push -q --follow-tags >/dev/null 2>/dev/null' > "$script"
                    gum spin --spinner dot --title "Pushing without tag" -- bash "$script" > /dev/null
                    if [ $? -ne 0 ]; then
                        rm "$script"
                        printf "Error on push\n" 1>&2
                        return 1
                    fi
                    rm "$script"
                fi
                set +m
                {
                    sleep $((delay * 60))
                    sleep 1 # delay a little more to be safe
                    if [ "$tagged" = "true" ]; then
                        if is_dev; then
                            notify-send -u low "DEBUG: Tagged: $tag_name"
                        elsez
                            git tag -ma "$tag_name"
                        fi

                        if [ $? -ne 0 ]; then
                            notify-send -u critical "Scheduled tag failed (on tag): $tag_name"
                            rm "$directory/.gitdelayedtag"
                            return 1
                        fi
                    fi

                    if is_dev; then
                        notify-send -u low "DEBUG: Sent tag: $tag_name"
                        rm "$directory/.gitdelayedtag"
                    else
                        git push --follow-tags >/dev/null 2>/dev/null
                        if [ $? -ne 0 ]; then
                            notify-send -u critical "Scheduled tag failed (on push): $tag_name"
                            rm "$directory/.gitdelayedtag"
                            return 1
                        fi
                        notify-send -u normal "Sent scheduled tag: $tag_name"
                        rm "$directory/.gitdelayedtag"
                    fi
                } &
                echo -n "$!">"$directory/.gitdelayedtag"
                disown
                set -m
                ;;

            "Do not push")
                return 0
                ;;
            *)
                printf 'Invalid case value\n' 1>&2
                return 99
                ;;
        esac
    else
        if gum confirm "Push?"; then
            script="$(mktemp)"

            if is_dev; then
                echo "pushed"
            else
                echo 'git push -q --follow-tags >/dev/null 2>/dev/null' > "$script"
                gum spin --spinner dot --title "Pushing" -- bash "$script" > /dev/null
                if [ $? -ne 0 ]; then
                    rm "$script"
                    printf "Error on push\n" 1>&2
                    return 1
                fi
                rm "$script"
            fi
        fi
    fi
}

# FIXME: autogit does not and has never worked, fix or remove
autogit()
{
    # if [ -z "$1" ]; then
    #     exer="$(gum choose $(ls))"
    #     if [ $? -ne 0 ]; then
    #         return 2
    #     fi
    # else
    #     exer="$1"
    # fi

    # == Add ==
    git add .

    if [ $? -ne 0 ]; then
        printf "Error on add\n" 1>&2
        return 1
    fi

    # == Commit ==
    path1="subject.pdf"
    if ! [ -f "$path1" ]; then
        commitmsg="$(gum input --width 25 --placeholder "Message")"
    else
        commitmsg="$(cat "$path1")"
    fi
    if [ -z "$commitmsg" ] || [ "$commitmsg" = "not submitted" ]; then
        git restore --staged .
        printf "message empty... aborting\n" 1>&2
        return 1
    fi
    gum spin --spinner dot --title "Commiting" -- git commit -m "$commitmsg" > /dev/null

    if [ $? -ne 0 ]; then
        printf "Error on commit\n" 1>&2
        return 1
    fi

    # == Tag ==

    if gum confirm "Tag?"; then
        if gum confirm "Use automatic tag?"; then
            if ! [ -f ".gittagcount" ]; then
                echo 0 > ".gittagcount"
            fi

            count=$(cat ".gittagcount")
            echo $((count + 1)) > ".gittagcount"
            count=$(cat ".gittagcount")
            tag_name="$(cat ".gittagbase" | tr -d '\n')-$(printf %04d $(echo "obase=2;$count" | bc))"
        else
            tag_name="$(gum input --width 25 --placeholder "Tag name")"
        fi

        git tag -ma "$tag_name"

         if [ $? -ne 0 ]; then
            printf "Error on tag\n" 1>&2
            return 1
        fi
    fi

    # == Push ==

    if gum confirm "Push?"; then
        script="$(mktemp)"
        echo 'git push -q --follow-tags >/dev/null 2>/dev/null' > "$script"
        gum spin --spinner dot --title "Pushing" -- bash "$script" > /dev/null
        rm "$script"
        if [ $? -ne 0 ]; then
            printf "Error on push\n" 1>&2
            return 1
        fi
    fi
}
