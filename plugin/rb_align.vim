if exists("loaded_rb_align")
  finish
endif
let loaded_rb_align=1

if !has('ruby')
  echomsg 'ruby support not available, rb_align plugin will not be loaded!'
  finish
endif

vmap <silent> <Leader>t= :call rb_align#AlignLeftEqual()<CR>
nmap <silent> <Leader>t= :set opfunc=rb_align#AlignLeftEqual_operator<CR>g@

vmap <silent> <Leader>t, :call rb_align#AlignLeftComma()<CR>
nmap <silent> <Leader>t, :set opfunc=rb_align#AlignLeftComma_operator<CR>g@

vmap <silent> <Leader>T, :call rb_align#AlignRightComma()<CR>
nmap <silent> <Leader>T, :set opfunc=rb_align#AlignRightComma_operator<CR>g@

vmap <silent> <Leader>adec :call rb_align#AlignDec()<CR>
nmap <silent> <Leader>adec :set opfunc=rb_align#AlignDec_operator<CR>g@

