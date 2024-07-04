if !has('vim9script')
    echoerr "This plugin requires vim9script support!"
    finish
endif

vim9script

if !exists('g:ncr_highlight_group')
    g:ncr_highlight_group = 'Visual'
endif

if !exists('g:ncr_always_highlight')
    # TODO: make this actually do something
    g:ncr_always_highlight = true
endif

g:has_patch_9_0_0620 = has("patch-9.0.0620")

import * as ncr from '../autoload/non-continuous-range.vim'

def Init(): void
    if !exists('b:ncr_selected_lines') | b:ncr_selected_lines = {} | endif
    if !exists('b:ncr_highlight_groups_ids') | b:ncr_highlight_groups_ids = [] | endif
    if !exists('b:ncr_selected_lines_buffer') | b:ncr_selected_lines_buffer = {} | endif
    if !exists('b:ncr_highlight_groups_ids_buffer') | b:ncr_highlight_groups_ids_buffer = [] | endif
enddef


autocmd BufEnter * Init()

command -nargs=* NCRExeOnRange ncr.ExecuteOnRange(<q-args>)
command -nargs=* NCRExeOnSelection ncr.ExecuteOnSelection(<q-args>)
command -range NCRSaveRange ncr.SaveRange(<line1>, <line2>)
command NCRShow ncr.GetSelection()
command NCRRestore ncr.RestoreSelection()
command NCRClear ncr.ClearSelection()

