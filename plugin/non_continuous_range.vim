if !has('vim9script')
    echoerr "This plugin requires vim9script support!"
    finish
endif

vim9script

if !exists('g:ncr_highlight_group')
    g:ncr_highlight_group = 'Visual'
endif

g:has_patch_9_0_0620 = has("patch-9.0.0620")

import autoload '../autoload/non_continuous_range.vim' as ncr

def Init(): void
    if !exists('b:ncr_selected_lines') | b:ncr_selected_lines = {} | endif
    if !exists('b:ncr_highlight_groups_ids') | b:ncr_highlight_groups_ids = [] | endif
    if !exists('b:ncr_selected_lines_buffer') | b:ncr_selected_lines_buffer = {} | endif
    if !exists('b:ncr_highlight_groups_ids_buffer') | b:ncr_highlight_groups_ids_buffer = [] | endif
enddef


autocmd BufEnter * Init()

command -nargs=* NCRExeOnRange ncr.ExecuteOnRange(<q-args>)
command -nargs=* NCRExeOnSelection ncr.ExecuteOnSelection(<q-args>)
command -range NCRAppend ncr.AppendRange(<line1>, <line2>)
command -range NCRSubtract ncr.SubtractRange(<line1>, <line2>)
command NCRShow ncr.GetSelection()
command NCRRestore ncr.RestoreSelection()
command NCRClear ncr.ClearSelection()

