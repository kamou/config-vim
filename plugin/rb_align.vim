
function! Align() range

  ruby << EOF

  b = VIM::Buffer.current

  s = VIM::evaluate('a:firstline').to_i
  e = VIM::evaluate('a:lastline').to_i

  p = '='
  r = /\s*#{p}\s*/
  p = " #{p} "

  c = 0

  lines = (s..e).collect { |n|

    line = b[n].split(r)

    c = line.size if line.size > c

    line
  }

  def size(line, c)
    c + 1 < line.size ? line[c].size : 0
  end

  0.upto(c - 2) { |c|

    m = lines.max { |l1, l2| size(l1, c) <=> size(l2, c) }

    f = "%-#{m[c].size}s"

    lines.each { |line|

      next unless c + 1 < line.size

      line[c] = f % line[c]
    }

    lines.each_with_index { |line, n|

      b[s + n] = line.join(p)
    }
  }

EOF

endfunction

function! Align_operator(type)
  :'[,']call Align()
endfunction

vmap <silent> <Leader>t= :call Align()<CR>
nmap <silent> <Leader>t= :set opfunc=Align_operator<CR>g@

