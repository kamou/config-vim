
if !exists('g:bzrstatus_vimdiff')
  let g:bzrstatus_vimdiff = 0
endif

command! -nargs=? -complete=file BzrStatus call bzrstatus#start(<f-args>)

