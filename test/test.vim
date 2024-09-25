vim9script

# check v:errors for failed tests

def TestVisualAppend(): void
    execute ":edit test/test_text.txt"
    execute "normal ggVj\<Esc>"
    execute ":'<,'>NCRAppend"
    execute "normal jjjjVkk\<Esc>"
    execute ":'<,'>NCRAppend"

    var output: string = trim(execute(":NCRShow", ""))
    assert_equal("[1, 2, 4, 5, 6]", output)
    execute ":NCRClear"
enddef

def TestRangeAppend(): void
    execute ":edit test/test_text.txt"
    execute ":1,3NCRAppend"
    execute ":5,7NCRAppend"

    var output: string = trim(execute(":NCRShow", ""))
    assert_equal("[1, 2, 3, 5, 6, 7]", output)
    execute ":NCRClear"
enddef

def TestVisualSubtract(): void
    execute ":edit test/test_text.txt"
    execute "normal ggVj\<Esc>"
    execute ":'<,'>NCRAppend"
    execute "normal jjjjVkk\<Esc>"
    execute ":'<,'>NCRAppend"
    execute "normal 4GVj\<Esc>"
    execute ":'<,'>NCRSubtract"

    var output: string = trim(execute(":NCRShow", ""))
    assert_equal("[1, 2, 6]", output)
    execute ":NCRClear"
enddef

def TestRangeSubtract(): void
    execute ":edit test/test_text.txt"
    execute ":1,3NCRAppend"
    execute ":5,7NCRAppend"
    execute ":2,3NCRSubtract"

    var output: string = trim(execute(":NCRShow", ""))
    assert_equal("[1, 5, 6, 7]", output)
    execute ":NCRClear"
enddef

def TestExeOnSelection(): void
    execute ":edit test/test_text.txt"
    execute "normal ggVjj\<Esc>"
    execute ":'<,'>NCRAppend"
    execute "normal GkVkk\<Esc>"
    execute ":'<,'>NCRAppend"
    execute ":NCRExeOnSelection s/[1-9]/\./g"

    var output: string = execute(":w !diff -q - test/test_exeonsel_test.txt", "")
    assert_equal("\n", output)
    execute ":NCRClear"
    execute ":bd!"
enddef

TestVisualAppend()
TestRangeAppend()
TestVisualSubtract()
TestRangeSubtract()
TestExeOnSelection()
