vim9script

# check v:errors for failed tests

def TestAppend(): bool
    execute ":edit test/test_text.txt"
    execute "normal Vj\<Esc>"
    execute ":'<,'>NCRAppend"
    execute "normal jjjjVkk\<Esc>"
    execute ":'<,'>NCRAppend"
    
    var output: string = trim(execute(":NCRShow", ""))
    assert_equal("[1, 2, 4, 5, 6]", output)
    return true
enddef

TestAppend()
