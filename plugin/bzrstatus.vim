
let g:BzrStatus_bzrcmd = 'bzr status -S --no-pending --versioned'
let g:BzrStatus_nextline = '^[-+R ][NDM][* ]\s\+\(.*\)$'
let g:BzrStatus_matchline = '^\([-+R ][NDM][* ]\|?  \|  \*\)\s\+\(.*\)$'
let g:BzrStatus_tmpbuf = 0
let g:BzrStatus_diffbuf = 0

command! -nargs=0 BzrStatus call bzrstatus#BzrStatus()

