
let g:bzrstatus_bzrcmd = 'bzr status -S --no-pending --versioned'

command! -nargs=? -complete=file BzrStatus call bzrstatus#start(<f-args>)

