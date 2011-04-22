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
if !exists("g:yasnippets_file")
    let g:yasnippets_file = expand($USERVIM.'/snippets.rb')
endif

if !exists("g:yasnippets_skeletons")
    let g:yasnippets_skeletons = expand($USERVIM.'/skeletons')
endif


" <<<1 Mappings and autocommands
exec "autocmd Syntax * syntax region Todo display oneline keepend"
    \ "start=/" . IMAP_GetPlaceHolderStart() . "/"
    \ "end=/" . IMAP_GetPlaceHolderEnd() . "/"
augroup skeleton
    autocmd!
    autocmd FileType * if line2byte(line('$') + 1) == -1 | call yasnippets#LoadSkeletonByFileType(&filetype) | endif
augroup END


command! -nargs=? -complete=custom,yasnippets#SelectSkeleton LoadSkeleton
            \ call yasnippets#LoadSkeletonByName(<q-args>)

ruby require 'yasnippets'

let &cpo = s:save_cpo

" vim:fdm=marker fmr=<<<,>>>
