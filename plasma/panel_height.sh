#!/usr/bin/env bash
# vim: set ts=4 sw=4 et:

print_usage() {
    cat <<EOF >&2
usage:
    $0 -s [width]  -- set panel height
    $0 -r          -- reset panel height
EOF
exit 2
}

die() {
    # args
    code=$1
    message=$2
    # /args

    echo "$message" >&2
    exit "$code"
}

# fail if qdbus6 is not installed
which qdbus6 &>/dev/null || die 3 'qdbus6 is not installed' 


TMP_DIR="/tmp/com.lolcatjpg.util_scripts.panel_height"
NORMAL_HEIGHT_FILE="${TMP_DIR}/normal_height"
[[ -d $TMP_DIR ]] || mkdir -p "$TMP_DIR"

set_height() {
    # args
    local height=$1
    # /args

    [[ $height =~ ^[0-9]+$ ]] || die 1 'height must be a positive integer'

    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'print(panels()[0].height)' > "$NORMAL_HEIGHT_FILE"
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "panels()[0].height = $height"
    
    exit 0
}

reset() {
    local height="$(cat "$NORMAL_HEIGHT_FILE")"
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "panels()[0].height = $height"

    exit 0
}

# get options

while getopts ':s:r' opt; do
    case "$opt" in
        s)  set_height "$OPTARG"
            ;;
        r)  reset
            ;;
        \?) print_usage
            ;;
    esac
done
shift $((OPTIND - 1))

print_usage  # no function was executed so some args were wrong

