" Decho.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Apr 18, 2012
"   Version: 1a	ASTRO-ONLY
" ---------------------------------------------------------------------
let s:keepcpo      = &cpo
set cpo&vim

if has("conceal")
 syn match	vimTodo contained	'^\s*".*\<D\%(func\|ret\|echo\|redir\)\s*(.*$' conceal
else
 syn match	vimTodo contained	'^\s*".*\<D\%(func\|ret\|echo\|redir\)\s*(.*$'
endif

syn keyword vimDbgName		Dfunc Dret Decho DechoWF DechoOn DechoOff DechoMsgOn DechoMsgOff DechoRemOn DechoRemOff DechoVarOn DechoVarOff DechoTabOn DechoTabOff Dredir containedin=vimFuncBody
syn keyword vimDbgName		Rfunc Rret Recho RechoWF RechoOn RechoOff RechoMsgOn RechoMsgOff RechoRemOn RechoRemOff RechoVarOn RechoVarOff RechoTabOn RechoTabOff Rredir containedin=vimFuncBody

hi def link vimDbgName	Debug

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
