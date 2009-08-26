
if exists('g:loaded_vmake')
  finish
endif
let g:loaded_vmake = 1

command -nargs=* VMake :call vmake#VMake(<f-args>)

