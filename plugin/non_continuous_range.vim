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

import * as ncr from '../autoload/non_continuous_range.vim'

command -nargs=* NCRExeOnRange ncr.ExecuteOnRange(<q-args>)
command -range NCRSaveRange ncr.SaveRange(<line1>, <line2>)
command NCRShow ncr.GetSelections()
command -nargs=* NCRExeOnSel ncr.ExecuteOnSelections(<q-args>)
command NCRRestore ncr.RestoreSelection()
