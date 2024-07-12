# vim-non-continuous-range

Run commands across non-continuous line ranges.

## Install

This plugin requires vim9script, but not necessarily vim9 itself. Some distributions compile the version of vim8 in their repositories with vim9script support, which this plugin aims to support. It has been tested on vim v8.2.

Using [vim-plug]{https://github.com/junegunn/vim-plug}:
    `Plug 'FMakosza/vim-non-continuous-range'`

Using [vundle]{https://github.com/VundleVim/Vundle.vim}:
    `Plugin 'FMakosza/vim-non-continuous-range'`

## Overview

non-continuous-range lets you run any valid `:execute` expression on an arbitrary selection of lines in the open buffer. You can select the lines visually or by passing a range of lines directly on the command line.

For example, `:NCRExeOnRange 1,5-9 s/    /\t/g` will replace four spaces in a row with a tab character on lines 1, 5, 6, 7, 8, and 9.

Make a visual selection and run `:'<,'>NCRAppend` to add the selection to a persistent per-buffer line selection list. Build up your selection with more `:'<,'>NCRAppend`s or subtract from it with `:'<,'>NCRSubtract`, then run `:NCRExeOnSelection s/    /\t/g` to substitute across your entire selection at once.

`:NCRClear` will clear the selection, and `:NCRRestore` will restore the most recent selection after it has been wiped by `:NCRClear` or one of the `:NCRExeOn` commands.

Both `:NCRExeOn*` commands will take your line range and, starting from the bottom, run `:execute {expression}` on every line sequentially.

Please read the included [vim doc](doc/non-continuous-range.txt) for more details, including a comprehensive list of commands and all available configuration options.

## License

This plugin is licensed under the GNU General Public License v3.0.

