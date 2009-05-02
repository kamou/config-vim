
if exists('g:loaded_tags_utils') || &cp
 finish
endif
let g:loaded_tags_utils = 1

nmap <silent> gf :call tags_utils#TagsFindFile('', 0)<CR>
nmap <silent> gF :call tags_utils#TagsFindFile('', 1)<CR>

command! -nargs=1 GF call tags_utils#TagsFindFile(<f-args>, 1)

autocmd! BufNewFile *:* nested call tags_utils#TagsFindFile(bufname('%'), 3)

command! -nargs=1 TagsFindInclude call tags_utils#TagsFindInclude('', <args>)

nmap <silent> <Leader>li :call tags_utils#TagsFindInclude(v:register, '^'.expand('<cword>').'$')<CR>

command! -nargs=0 TagsRename call tags_utils#TagsRename()

