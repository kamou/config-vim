#!/usr/bin/env ruby

$delimeter      = '___'
$snippets       = []
$sksnippets     = []
$expand_pattern = 'keywordss'
$snippets_file  = VIM::evaluate("g:yasnippets_file")

def setdelimeter(delimeter)
    $delimeter = delimeter
end

def expand(new_pattern)
    if not new_pattern.include? 'keyword'
        VIM::command("echoerr 'Error in #$snippets_file: \"#{new_pattern}\" must contain \"keyword\"'")
    elsif block_given?
        old_pattern = $expand_pattern
        $expand_pattern = new_pattern
        yield
        $expand_pattern = old_pattern
    else
        $expand_pattern = new_pattern
    end
end

def defsnippet(*args)
    keyword = $expand_pattern.sub('keyword', args.shift)
    $snippets << [keyword] + args
end

def defsksnippet(*args)
    keyword = $expand_pattern.sub('keyword', args.shift)
    $sksnippets << [keyword] + args
end

 load $snippets_file

for snippet in $snippets
    keyword = snippet.shift
    keyword.gsub!("'", "''")
    text = snippet.pop.dup
    text.strip!
    text.gsub!("\n", '\<cr>')
    text.gsub!(/\^\^\^\\<cr>/, "\\<C-R>=yasnippets#FreezeIndent()\\<CR>\\<CR>\\<C-R>=yasnippets#UnfreezeIndent()\\<CR>")
    for filetype in snippet
        filetype = '' if filetype.to_s == 'all'
        VIM::command("call IMAP('#{keyword}', \"#{text}\", '#{filetype}', '<+', '+>')")
    end
end

for snippet in $sksnippets
    keyword = snippet.shift
    keyword.gsub!("'", "''")
    text = snippet.pop.dup
    text.strip!
    text.gsub!("\n", '\<cr>')
    text.gsub!(/\^\^\^\\<cr>/, "\\<C-R>=yasnippets#FreezeIndent()\\<CR>\\<CR>\\<C-R>=yasnippets#UnfreezeIndent()\\<CR>")
    for filetype in snippet
        filetype = '' if filetype.to_s == 'all'
        VIM::command("call IMAP('#{keyword}', \"#{text}\", '#{filetype}', '<+', '+>', 1)")
    end
end

