if !has('vim9script')
    echoerr "This plugin requires vim9script support!"
    finish
endif

vim9script
g:loaded_ncr = true

import * as ncr from '../autoload/non_continuous_range.vim'

command -nargs=* NCRExeOnRange ncr.ExecuteOnRange(<q-args>)
command -range NCRSaveRange ncr.SaveRange(<line1>, <line2>)
command NCRShow ncr.GetSelections()
command -nargs=* NCRExeOnSel ncr.ExecuteOnSelections(<q-args>)
