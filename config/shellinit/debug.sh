#!/bin/sh

is_dev()
{
    if [ "$DEBUG_ENV" = "true" ]; then
        return 0
    fi
    return 1
}

dev()
{
    if [ $# -eq 0 ]; then
        if is_dev; then
            echo "Already running a shell dev environment"
            return 128
        fi
        export DEBUG_ENV="true"
    else
        DEBUG_ENV="true" "$@"
        local ex="$?"
        echo "[exit ($ex)]"
        return $ex
    fi
}

dev_log()
{
    if is_dev; then
        echo -en "\033[33m[DEBUG] "
        echo -n "$@"
        echo -e "\033[0m"
    fi
}
