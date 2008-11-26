" Yet another plugin for text snippets
"     Version:    3.0 2007.08.04
"     Author:     Valyaeff Valentin <hhyperr AT gmail DOT com>
"     License:    GPL
"
" Copyright 2007 Valyaeff Valentin
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.


" <<<1 Initialization
if exists("loaded_yasnippets")
    finish
endif
let loaded_yasnippets = 1

let s:save_cpo = &cpo
set cpo&vim

" <<<1 Variables
if !exists("g:yasnippets_nlkey")
    let g:yasnippets_nlkey = "<cr>"
endif

if !exists("g:yasnippets_nlkey_insert")
    let g:yasnippets_nlkey_insert = "\<cr>"
endif

if !exists("g:yasnippets_file")
    let g:yasnippets_file = expand('~/.vim/snippets.rb')
endif

if !exists("g:yasnippets_skeletons")
    let g:yasnippets_skeletons = expand('~/.vim/skeletons')
endif

let g:yasnippets_nl        = {}
let g:yasnippets_nl['all'] = []


" <<<1 Mappings and autocommands
exec "inoremap ".g:yasnippets_nlkey." <c-r>=yasnippets#NLexpand()<cr>"
exec "autocmd Syntax * syntax region Todo display oneline keepend"
    \ "start=/" . IMAP_GetPlaceHolderStart() . "/"
    \ "end=/" . IMAP_GetPlaceHolderEnd() . "/"
augroup skeleton
    autocmd!
    autocmd FileType * if line2byte(line('$') + 1) == -1 | call yasnippets#LoadSkeletonByFileType(&filetype) | endif
augroup END


command! -nargs=? -complete=custom,yasnippets#SelectSkeleton LoadSkeleton
            \ call yasnippets#LoadSkeletonByName(<q-args>)

" <<<1 Read user snippets
ruby <<END
$delimeter      = '___'
$snippets       = []
$nlsnippets     = []
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

def defnlsnippet(*args)
    $nlsnippets << args
end

def defsksnippet(*args)
    keyword = $expand_pattern.sub('keyword', args.shift)
    $sksnippets << [keyword] + args
end

load $snippets_file

for snippet in $snippets
    keyword = snippet.shift
    keyword.gsub!("'", "''")
    text = snippet.pop
    text.strip!
    text.gsub!("\n", '\<cr>')
    text.gsub!(/\^\^\^\\<cr>/, "\\<C-R>=yasnippets#FreezeIndent()\\<CR>\\<CR>\\<C-R>=yasnippets#UnfreezeIndent()\\<CR>")
    for filetype in snippet
        filetype = '' if filetype.to_s == 'all'
        VIM::command("call IMAP('#{keyword}', \"#{text}\", '#{filetype}', '<+', '+>')")
    end
end

for snippet in $nlsnippets
    left, right = snippet.first.split($delimeter)
    text = snippet.last
    for filetype in snippet[1..-2]
        if VIM::evaluate("has_key(g:yasnippets_nl, '#{filetype}')").to_i == 0
            VIM::command("let g:yasnippets_nl['#{filetype}'] = []")
        end
        VIM::command("let g:yasnippets_nl['#{filetype}'] += [['#{left}', '#{right}', \"#{text}\"]]")
    end
end

for snippet in $sksnippets
    keyword = snippet.shift
    keyword.gsub!("'", "''")
    text = snippet.pop
    text.strip!
    text.gsub!("\n", '\<cr>')
    text.gsub!(/\^\^\^\\<cr>/, "\\<C-R>=yasnippets#FreezeIndent()\\<CR>\\<CR>\\<C-R>=yasnippets#UnfreezeIndent()\\<CR>")
    for filetype in snippet
        filetype = '' if filetype.to_s == 'all'
        VIM::command("call IMAP('#{keyword}', \"#{text}\", '#{filetype}', '<+', '+>', 1)")
    end
end

END
" >>>

let &cpo = s:save_cpo
" vim:fdm=marker fmr=<<<,>>>
