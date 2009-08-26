
function! vmake#VMake(...)

  let cmd = ':silent make '

  for arg in a:000
    let cmd .= ' "'.escape(arg, '"').'"'
  endfor

  exe cmd

  let has_errors = 0

  if 0 != v:shell_error
    let has_errors = 1
  else
    for e in getqflist()
      if 0 != e.valid
        let has_errors = 1
        break
      endif
    endfor
  endif

  if has_errors
    copen
  else
    quit
  end

endfunction

