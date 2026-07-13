#!/bin/sh

function change_theme()
{
    # TODO
    echo "Changing themes is not yet implemented" 1>&2
    return 1
}

export THEME_COLOR_BACKGROUND='#212121'
export THEME_COLOR_ACCENT='#FF8800'

export GUM_INPUT_CURSOR_FOREGROUND="$THEME_COLOR_ACCENT"
export GUM_INPUT_PROMPT_FOREGROUND="#0FF"
