
" Highlight trailing white spaces, tabs.
setlocal list

" Dictionary for completion.
setlocal dictionary+=$USERVIM/dictionaries/make.dic

" Matchit.
let b:match_words = '^\s*ifn\?\(eq\|def\)\>:^\s*else\>:^\s*endif\>,^\s*define\>:^\s*endef\>'

