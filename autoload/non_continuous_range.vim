vim9script

b:selected_lines = []
b:highlight_groups_ids = []

b:selected_lines_buffer = []
b:highlight_groups_ids_buffer = []

def EvalRangeString(range_string: string): list<number>
    # evaluates a valid range string into a list of line numbers. Plain integers
    # are left alone, x-y is expanded into a list of every number between x and y
    var ranges: list<string> = split(range_string, ",")
    var lines: list<number> = []
    for range in ranges
        if stridx(range, "-") == -1
            add(lines, str2nr(range))
        else
            # splits the range on the -, and converts the strings to numbers
            # so they can be sorted (so range always gets the smaller number first)
            #
            # also note that map() modifies in-place - for typing related
            # reasons (see https://groups.google.com/g/vim_dev/c/WcYKLLpzsP0)
            # mapnew() has to be used to return a new list instead
            var [a: number, b: number] = sort(
                mapnew(split(range, "-"), "str2nr(v:val)"),
                "n")
            for i in range(a, b)
                add(lines, i)
            endfor
        endif
    endfor
    # sort and reverse the line numbers so that later lines are executed
    # first - this means that if the command deletes lines, the line indices
    # aren't thrown out of alignment
    return uniq(reverse(sort(lines)))
enddef

def HighlightLines(lines: list<number>): void
    # before this patch, matchaddpos() could only take a maximum of eight line
    # indices per call
    if g:has_patch_9_0_0620
        add(b:highlight_groups_ids, matchaddpos(g:ncr_highlight_group, lines))
    else
        for line in lines
            add(b:highlight_groups_ids, matchaddpos(g:ncr_highlight_group, [line]))
        endfor
    endif
enddef

def ClearHighlights(): void
    for id in b:highlight_groups_ids
        matchdelete(id)
    endfor
    b:highlight_groups_ids = []
enddef

export def SaveRange(range_start: number, range_end: number): void
    if range_start == range_end
        add(b:selected_lines, range_start)
        HighlightLines([range_start])
    else
        var range_string: string = range_start .. "-" .. range_end
        add(b:selected_lines, range_string)
        HighlightLines(EvalRangeString(range_string))
    endif
enddef

export def GetSelections(): void
    echo b:selected_lines
enddef

export def ExecuteOnSelections(command: string): void
    ExecuteOnRange(join(b:selected_lines, ",") .. " " .. command)
    b:highlight_groups_ids_buffer = b:highlight_groups_ids
    ClearHighlights()
    b:selected_lines_buffer = b:selected_lines
    b:selected_lines = []
enddef

export def RestoreSelection(): void
    if b:selected_lines_buffer == []
        echoerr "No selection to restore!"
        finish
    endif

    b:selected_lines = b:selected_lines_buffer
    HighlightLines(b:selected_lines_buffer)
enddef

export def ExecuteOnRange(args: string): void
    # expects a range string: a comma-separated list of either integers, or
    # pairs of integers separated by a "-" character
    var first_space_index: number = stridx(args, " ")

    var range_string: string = args[ : first_space_index]
    var cmd: string = args[first_space_index + 1 : ]

    const lines: list<number> = EvalRangeString(range_string)
    for line in lines
        try
            execute ":" .. line .. cmd
        catch /.*/
            # ignores all errors - ideally should selectively echo useful
            # errors to the user while continuing to iterate
            continue
        endtry
    endfor
enddef

#command -nargs=* NCRExeOnRange ExecuteOnRange(<q-args>)
#command -range NCRSaveRange SaveRange(<line1>, <line2>)
#command NCRGetSel GetSelections()
#command -nargs=* NCRExeOnSel ExecuteOnSelections(<q-args>)
