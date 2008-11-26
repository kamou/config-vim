
function! qfdo#QuickFixDo(commands)

  for d in getqflist()

    exe 'buf '.d.bufnr
    cal cursor(d.lnum, d.col)
    exe a:commands

  endfor

endfunction

function! qfdo#QuickFixFileDo(commands)

  let bid = -1

  for d in getqflist()

    if bid == d.bufnr
      continue
    endif

    let bid = d.bufnr

    exe 'buf '.bid
    exe a:commands

  endfor

endfunction

