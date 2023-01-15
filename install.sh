#!/usr/bin/env bash

# check if stdout is a terminal...
if test -t 1; then

    # see if it supports colors...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test "$ncolors" -ge 8; then
        bold="$(tput bold)"
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
    fi
fi

ICONS_DIR=~/.local/share/icons
THEME_NAME=MSTCRSR

declare -A CURSOR_MAP=(
    [Arrow_Crossed]=move
    [Arrow_Horizontal]=col-resize
    [Arrow_Vertical]=row-resize
    [Bg_Loading]=progress
    [Crosshair]=cross
    [D_Arrow_1]=nw-resize
    [D_Arrow_2]=ne-resize
    [Handwriting]=pencil
    [Hyperlink]=pointer
    [Idle]=default
    [Input]=copy
    [Loading]=watch
    [Prohibition]=not-allowed
    [Textbar]=text
)

declare -A ALIASES=(
    [default]="left_ptr arrow X_cursor"
    [pointer]="hand hand2"
    [progress]="left_ptr_watch"
    [watch]="wait"
    [cross]="crosshair tcross diamond_cross"
    [copy]="dnd-copy dnd-link alias"
    [not-allowed]="no-drop dnd-none"
    [move]="fleur hand1 all-scroll"
    [nw-resize]="se-resize nwse-resize sizing"
    [ne-resize]="sw-resize nesw-resize"
    [col-resize]="e-resize w-resize ew-resize sb_h_double_arrow"
    [row-resize]="n-resize s-resize ns-resize sb_v_double_arrow"
    [text]="xterm"
)

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
    -h | --help)
        cat <<HELP
Pixel-style cursor theme for X11
Options:
  -m | --cursor-map     -- Print out cursor map and aliases
  -d | --theme-dir      -- Change installation directory
                           [DEFAULT: ${magenta}$ICONS_DIR${normal}]
  -s | --set-as-default -- Set this theme as default after installation
HELP
        if ! command -v xcursorgen &> /dev/null; then
            echo -e "${bold}${yellow}Warning:${normal} ${green}xcursorgen${normal} is required to install this theme, but it is not found"
        fi
        exit 1
        ;;
    -m | --cursor-map)
        printf "${bold}${blue}%-16s ${green}%s${normal}\n" Directory "X11 Cursor"
        for cursor in "${!CURSOR_MAP[@]}"; do
            printf "${blue}%-16s ${green}%s${normal}\n" "$cursor" "${CURSOR_MAP[$cursor]}"
        done
        echo
        for source in "${!ALIASES[@]}"; do
            echo -e "Aliases for ${green}$source${normal}:"
            for alias in ${ALIASES[$source]}; do
                echo "  - $alias"
            done
        done
        exit 1
        ;;
    -d | --theme-dir)
        shift
        ICONS_DIR="$1"
        ;;
    -s | --set-as-default)
        set_as_default=1
        ;;
    *)
        echo "Invalid option '$1'"
        echo "Type $0 --help for more information"
        exit 1
        ;;
esac; shift; done
[[ "$1" == '--' ]] && shift

if ! command -v xcursorgen &> /dev/null; then
    echo -e "${bold}${red}Error:${normal} ${green}xcursorgen${normal} is required to install this theme, but it is not found"
    exit 1
fi

[ -d "$ICONS_DIR/$THEME_NAME" ] || mkdir -p "$ICONS_DIR/$THEME_NAME/cursors"

for cursor in "${!CURSOR_MAP[@]}"; do
    dir="${0%/*}/src/$cursor"
    dest="$ICONS_DIR/$THEME_NAME/cursors/${CURSOR_MAP[$cursor]}"
    (
        cd "$dir" || exit 1
        xcursorgen cursor.xcg "$dest"
    )
done

for source in "${!ALIASES[@]}"; do
    for alias in ${ALIASES[$source]}; do
        ln -sf "$source" "$ICONS_DIR/$THEME_NAME/cursors/$alias"
    done
done

if [ -n "$set_as_default" ]; then
    sed -i "s/^\(Inherits=\).*\$/\1$THEME_NAME/" ~/.icons/default/index.theme
    sed -i "s/^\(gtk-cursor-theme-name=\).*\$/\1$THEME_NAME/" ~/.config/gtk-3.0/settings.ini
fi

