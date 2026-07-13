#!/bin/sh

ws()
{
    game="$1"
    item="$2"
    steamcmd +login anonymous +workshop_download_item "$game" "$item" +quit
}