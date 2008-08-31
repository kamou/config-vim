
rubyfile $USERVIM/plugin/rb_align.rb

ruby << EOF

def align_range(left, pre_match, surround_pre, delim_match, surround_post, post_match, range = nil)

  b = VIM::Buffer.current
  s = VIM::evaluate('a:firstline').to_i
  e = VIM::evaluate('a:lastline').to_i

  align(b, left, pre_match, surround_pre, delim_match, surround_post, post_match, s, e, range)

end

EOF

function! AlignLeftEqual() range
  ruby align_range(true, '\s+|[^=<>+-]', ' ', '=', ' ', '\s*')
endfunction

function! AlignLeftEqual_operator(type)
  :'[,']call AlignLeftEqual()
endfunction

vmap <silent> <Leader>t= :call AlignLeftEqual()<CR>
nmap <silent> <Leader>t= :set opfunc=AlignLeftEqual_operator<CR>g@

function! AlignLeftComma() range
  ruby align_range(true, '\s*', '', ',', ' ', '\s*')
endfunction

function! AlignLeftComma_operator(type)
  :'[,']call AlignLeftComma()
endfunction

vmap <silent> <Leader>t, :call AlignLeftComma()<CR>
nmap <silent> <Leader>t, :set opfunc=AlignLeftComma_operator<CR>g@

function! AlignRightComma() range
  ruby align_range(false, '\s*', '', ',', ' ', '\s*')
endfunction

function! AlignRightComma_operator(type)
  :'[,']call AlignRightComma()
endfunction

vmap <silent> <Leader>T, :call AlignRightComma()<CR>
nmap <silent> <Leader>T, :set opfunc=AlignRightComma_operator<CR>g@

function! AlignDec() range
  ruby align_range(true, '(\b(static|const|volatile|enum|struct|union)\b\s+)*\w+\s*', ' ', ['\**', 3], '', '\s*', 0..0)
endfunction

function! AlignDec_operator(type)
  :'[,']call AlignDec()
endfunction

vmap <silent> <Leader>adec :call AlignDec()<CR>
nmap <silent> <Leader>adec :set opfunc=AlignDec_operator<CR>g@

