
if exists('g:loaded_cscope_findfile') || &cp || !has('cscope')
 finish
endif

let g:loaded_cscope_findfile = 1

" Find a file, first using findfile(), and if no results is found and a cscope
" connection is available, using 'cscope find file'. If goto_line is not 0,
" then jump to line if its present (:xxx after the filename). If file_expr is
" not empty and goto_line is 2, then the :xxx directive must be present.
function! s:CscopeFindFile(file_expr, goto_line)

  let goto_line = a:goto_line

  let bufname = bufname('%')

  if empty(a:file_expr)

    " No file_expr passed as argument, use filename on the current cursor
    " position.

    let fname = expand('<cfile>')

    if goto_line

      let line = getline('.')[col('.') - 1 : ]
      let match = matchlist(line, '^\f\+:\(\d\+\)')

      if !empty(match)
        let goto_line = str2nr(match[1])
      end

    endif

  else

    " Use file_expr argument.

    let fname = a:file_expr

    if goto_line

      let match = matchlist(fname, '^\(\f\+\):\(\d\+\)$')

      if empty(match)
        if 2 == goto_line
          return
        end
      else
        let fname = match[1]
        let goto_line = str2nr(match[2])
      endif

    endif

  endif

  let file = findfile(fname)

  if empty(file)
    if !cscope_connection()
      return
    endif
    silent! exe 'csc f f '.fname
  else
    silent! exe 'e '.file
  endif

  " Did it work, i.e. the buffer changed?
  if bufname !=# bufname('%')
    if goto_line
      call cursor(goto_line, 1)
    endif
  endif

endfunction

nmap <silent> gf :call s:CscopeFindFile('', 0)<CR>
nmap <silent> gF :call s:CscopeFindFile('', 1)<CR>

command! -nargs=1 GF call s:CscopeFindFile(<f-args>, 1)

autocmd! BufNewFile *:* nested call s:CscopeFindFile(bufname('%'), 2)

