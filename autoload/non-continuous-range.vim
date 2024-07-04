vim9script

# use dictionary keys as set
b:ncr_selected_lines = {}
b:ncr_highlight_groups_ids = []

b:ncr_selected_lines_buffer = {}
b:ncr_highlight_groups_ids_buffer = []

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

    return lines
enddef

def HighlightLines(lines: list<number>): void
    # before this patch, matchaddpos() could only take a maximum of eight line
    # indices per call - see https://github.com/vim/vim/issues/11248
    if g:has_patch_9_0_0620
        add(b:ncr_highlight_groups_ids, matchaddpos(g:ncr_highlight_group, lines))
    else
        for line in lines
            add(b:ncr_highlight_groups_ids, matchaddpos(g:ncr_highlight_group, [line]))
        endfor
    endif
enddef

def ClearHighlights(): void
    for id in b:ncr_highlight_groups_ids
        matchdelete(id)
    endfor
    b:ncr_highlight_groups_ids = []
enddef

export def SaveRange(range_start: number, range_end: number): void
    if range_start == range_end
        b:ncr_selected_lines[range_start] = 1
        HighlightLines([range_start])
    else
        var lines: list<number> = EvalRangeString(range_start .. "-" .. range_end)
        for line in lines
            b:ncr_selected_lines[line] = 1
        endfor
        HighlightLines(lines)
    endif
enddef

export def GetSelection(): void
    echo keys(b:ncr_selected_lines)
enddef

export def ClearSelection(): void
    b:ncr_selected_lines_buffer = b:ncr_selected_lines
    b:ncr_selected_lines = {}
    b:ncr_highlight_groups_ids_buffer = b:ncr_highlight_groups_ids
    ClearHighlights()
enddef

def ExecuteOnLines(lines: list<number>, cmd: string): void
    # sort and reverse the line numbers so that later lines are executed
    # first - this means that if the command deletes lines, the line indices
    # aren't thrown out of alignment
    for line in uniq(reverse(sort(lines)))
        try
            #echo "Running :" .. line .. cmd
            execute ":" .. line .. cmd
        catch /.*/
            # ignores all errors - ideally should selectively echo useful
            # errors to the user while continuing to iterate
            continue
        endtry
    endfor
enddef

export def ExecuteOnSelection(cmd: string): void
    ExecuteOnLines(mapnew(keys(b:ncr_selected_lines), "str2nr(v:val)"), cmd)
    b:ncr_highlight_groups_ids_buffer = b:ncr_highlight_groups_ids
    b:ncr_selected_lines_buffer = b:ncr_selected_lines
    ClearHighlights()
    b:ncr_selected_lines = {}
enddef

export def ExecuteOnRange(args: string): void
    # expects a range string: a comma-separated list of either integers, or
    # pairs of integers separated by a "-" character
    var first_space_index: number = stridx(args, " ")

    var range_string: string = args[ : first_space_index]
    var cmd: string = args[first_space_index + 1 : ]

    ExecuteOnLines(EvalRangeString(range_string), cmd)
enddef

export def RestoreSelection(): void
    if b:ncr_selected_lines_buffer == {}
        echoerr "No selection to restore!"
        finish
    endif

    b:ncr_selected_lines = b:ncr_selected_lines_buffer
    HighlightLines(EvalRangeString(join(keys(b:ncr_selected_lines_buffer), ",")))
enddef

