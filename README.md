## Pixel-style cursor theme for X11
![](https://i.imgur.com/Rs0l1hL.gif)

Once this was a windows theme. All I did was convert that with [cursor-converter](https://github.com/avaunit02/cursor-converter) to X11 format.

### Installation
Just run `install.sh`. It will use [xcursorgen](https://github.com/freedesktop/xcursorgen) to generate cursors and put them in `~/.local/share/icons/MSTCRSR/cursors`.
With `--set-as-defult` option it will set this theme as default.

### Configuration
You can change what icon maps to what X cursor by editing `CURSOR_MAP` and `ALIASES` arrays in the install script.
