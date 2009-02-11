
let g:bzrstatus_bzrcmd = 'bzr status -S --no-pending --versioned'
let g:bzrstatus_nextline = '^[-+R ][NDM][* ]\s\+\(.*\)$'
let g:bzrstatus_matchline = '^\([-+R ][NDM][* ]\|?  \|  \*\)\s\+\(.*\)$'
let g:bzrstatus_tmpbuf = 0
let g:bzrstatus_diffbuf = 0

command! -nargs=0 BzrStatus call bzrstatus#start()

