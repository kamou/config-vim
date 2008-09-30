"        File: imaps.vim
"     Authors: Srinath Avadhanula <srinath AT fastmail.fm>
"              Benji Fisher <benji AT member.AMS.org>
"              
"         WWW: http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/vim-latex/vimfiles/plugin/imaps.vim?only_with_tag=MAIN
"
" Description: insert mode template expander with cursor placement
"              while preserving filetype indentation.
"
"     $Id: imaps.vim 997 2006-03-20 09:45:45Z srinathava $
"
" Documentation: {{{
"
" Motivation:
" this script provides a way to generate insert mode mappings which do not
" suffer from some of the problem of mappings and abbreviations while allowing
" cursor placement after the expansion. It can alternatively be thought of as
" a template expander. 
"
" Consider an example. If you do
"
" imap lhs something
"
" then a mapping is set up. However, there will be the following problems:
" 1. the 'ttimeout' option will generally limit how easily you can type the
"    lhs. if you type the left hand side too slowly, then the mapping will not
"    be activated.
" 2. if you mistype one of the letters of the lhs, then the mapping is
"    deactivated as soon as you backspace to correct the mistake.
"
" If, in order to take care of the above problems, you do instead
"
" iab lhs something
"
" then the timeout problem is solved and so is the problem of mistyping.
" however, abbreviations are only expanded after typing a non-word character.
" which causes problems of cursor placement after the expansion and invariably
" spurious spaces are inserted.
" 
" Usage Example:
" this script attempts to solve all these problems by providing an emulation
" of imaps wchich does not suffer from its attendant problems. Because maps
" are activated without having to press additional characters, therefore
" cursor placement is possible. furthermore, file-type specific indentation is
" preserved, because the rhs is expanded as if the rhs is typed in literally
" by the user.
"  
" The script already provides some default mappings. each "mapping" is of the
" form:
"
" call IMAP (lhs, rhs, ft)
" 
" Some characters in the RHS have special meaning which help in cursor
" placement.
"
" Example One:
"
" 	call IMAP ("bit`", "\\begin{itemize}\<cr>\\item <++>\<cr>\\end{itemize}<++>", "tex")
" 
" This effectively sets up the map for "bit`" whenever you edit a latex file.
" When you type in this sequence of letters, the following text is inserted:
" 
" \begin{itemize}
" \item *
" \end{itemize}<++>
"
" where * shows the cursor position. The cursor position after inserting the
" text is decided by the position of the first "place-holder". Place holders
" are special characters which decide cursor placement and movement. In the
" example above, the place holder characters are <+ and +>. After you have typed
" in the item, press <C-j> and you will be taken to the next set of <++>'s.
" Therefore by placing the <++> characters appropriately, you can minimize the
" use of movement keys.
"
" NOTE: Set g:Imap_UsePlaceHolders to 0 to disable placeholders altogether.
" Set 
" 	g:Imap_PlaceHolderStart and g:Imap_PlaceHolderEnd
" to something else if you want different place holder characters.
" Also, b:Imap_PlaceHolderStart and b:Imap_PlaceHolderEnd override the values
" of g:Imap_PlaceHolderStart and g:Imap_PlaceHolderEnd respectively. This is
" useful for setting buffer specific place hoders.
" 
" Example Two:
" You can use the <C-r> command to insert dynamic elements such as dates.
"	call IMAP ('date`', "\<c-r>=strftime('%b %d %Y')\<cr>", '')
"
" sets up the map for date` to insert the current date.
"
" }}}

" line continuation used here.
let s:save_cpo = &cpo
set cpo&vim

" ==============================================================================
" Script Options / Variables
" ============================================================================== 
" Options {{{
if !exists('g:Imap_StickyPlaceHolders')
	let g:Imap_StickyPlaceHolders = 1
endif
if !exists('g:Imap_DeleteEmptyPlaceHolders')
	let g:Imap_DeleteEmptyPlaceHolders = 1
endif
" }}}
" Variables {{{
" s:LHS_{ft}_{char} will be generated automatically.  It will look like
" s:LHS_tex_o = 'fo\|foo\|boo' and contain all mapped sequences ending in "o".
" s:Map_{ft}_{lhs} will be generated automatically.  It will look like
" s:Map_c_foo = 'for(<++>; <++>; <++>)', the mapping for "foo".
"
" }}}

" ==============================================================================
" functions for easy insert mode mappings.
" ==============================================================================
" IMAP: Adds a "fake" insert mode mapping. {{{
"       For example, doing
"           IMAP('abc', 'def' ft) 
"       will mean that if the letters abc are pressed in insert mode, then
"       they will be replaced by def. If ft != '', then the "mapping" will be
"       specific to the files of type ft. 
"
"       Using IMAP has a few advantages over simply doing:
"           imap abc def
"       1. with imap, if you begin typing abc, the cursor will not advance and
"          long as there is a possible completion, the letters a, b, c will be
"          displayed on on top of the other. using this function avoids that.
"       2. with imap, if a backspace or arrow key is pressed before completing
"          the word, then the mapping is lost. this function allows movement. 
"          (this ofcourse means that this function is only limited to
"          left-hand-sides which do not have movement keys or unprintable
"          characters)
"       It works by only mapping the last character of the left-hand side.
"       when this character is typed in, then a reverse lookup is done and if
"       the previous characters consititute the left hand side of the mapping,
"       the previously typed characters and erased and the right hand side is
"       inserted

" IMAP: set up a filetype specific mapping.
" Description:
"   "maps" the lhs to rhs in files of type 'ft'. If supplied with 2
"   additional arguments, then those are assumed to be the placeholder
"   characters in rhs. If unspecified, then the placeholder characters
"   are assumed to be '<+' and '+>' These placeholder characters in
"   a:rhs are replaced with the users setting of
"   [bg]:Imap_PlaceHolderStart and [bg]:Imap_PlaceHolderEnd settings.
"
function! IMAP(lhs, rhs, ft, ...)

	" Find the place holders to save for IMAP_PutTextWithMovement() .
	if a:0 < 2
		let phs = '<+'
		let phe = '+>'
	else
		let phs = a:1
		let phe = a:2
	endif

	let hash = s:Hash(a:lhs)
	let s:Map_{a:ft}_{hash} = a:rhs
	let s:phs_{a:ft}_{hash} = phs
	let s:phe_{a:ft}_{hash} = phe
	let s:skel_{a:ft}_{hash} = exists('a:3')

	" Add a:lhs to the list of left-hand sides that end with lastLHSChar:
	let lastLHSChar = a:lhs[strlen(a:lhs)-1]
	let hash = s:Hash(lastLHSChar)
	if !exists("s:LHS_" . a:ft . "_" . hash)
		let s:LHS_{a:ft}_{hash} = escape(a:lhs, '\')
	else
		let s:LHS_{a:ft}_{hash} = escape(a:lhs, '\') .'\|'.  s:LHS_{a:ft}_{hash}
	endif

	" map only the last character of the left-hand side.
	if lastLHSChar == ' '
		let lastLHSChar = '<space>'
	end
	exe 'inoremap <silent>'
				\ escape(lastLHSChar, '|')
				\ '<C-r>=IMAP_LookupCharacter("' .
				\ escape(lastLHSChar, '\|"') .
				\ '")<CR>'
endfunction

" }}}
" IMAP_list:  list the rhs and place holders corresponding to a:lhs {{{
"
" Added mainly for debugging purposes, but maybe worth keeping.
function! IMAP_list(lhs)
	let char = a:lhs[strlen(a:lhs)-1]
	let charHash = s:Hash(char)
	if exists("s:LHS_" . &ft ."_". charHash) && a:lhs =~ s:LHS_{&ft}_{charHash}
		let ft = &ft
	elseif exists("s:LHS__" . charHash) && a:lhs =~ s:LHS__{charHash}
		let ft = ""
	else
		return ""
	endif
	let hash = s:Hash(a:lhs)
	return "rhs = " . s:Map_{ft}_{hash} . " place holders = " .
				\ s:phs_{ft}_{hash} . " and " . s:phe_{ft}_{hash}
endfunction
" }}}
" IMAP_LookupCharacter: inserts mapping corresponding to this character {{{
"
" This function extracts from s:LHS_{&ft}_{a:char} or s:LHS__{a:char}
" the longest lhs matching the current text.  Then it replaces lhs with the
" corresponding rhs saved in s:Map_{ft}_{lhs} .
" The place-holder variables are passed to IMAP_PutTextWithMovement() .
function! IMAP_LookupCharacter(char)
	if IMAP_GetVal('Imap_FreezeImap', 0) == 1
		return a:char
	endif
	let charHash = s:Hash(a:char)

	" The line so far, including the character that triggered this function:
	let text = strpart(getline("."), 0, col(".")-1) . a:char
	" Prefer a local map to a global one, even if the local map is shorter.
	" Is this what we want?  Do we care?
	" Use '\V' (very no-magic) so that only '\' is special, and it was already
	" escaped when building up s:LHS_{&ft}_{charHash} .
	if exists("s:LHS_" . &ft . "_" . charHash)
				\ && text =~ "\\C\\V\\(" . s:LHS_{&ft}_{charHash} . "\\)\\$"
		let ft = &ft
	elseif exists("s:LHS__" . charHash)
				\ && text =~ "\\C\\V\\(" . s:LHS__{charHash} . "\\)\\$"
		let ft = ""
	else
		" If this is a character which could have been used to trigger an
		" abbreviation, check if an abbreviation exists.
		if a:char !~ '\k'
			let lastword = matchstr(getline('.'), '\k\+$', '')
			call IMAP_Debug('getting lastword = ['.lastword.']', 'imap')
			if lastword != ''
				" An extremeley wierd way to get around the fact that vim
				" doesn't have the equivalent of the :mapcheck() function for
				" abbreviations.
				let _a = @a
				exec "redir @a | silent! iab ".lastword." | redir END"
				let abbreviationRHS = matchstr(@a."\n", "\n".'i\s\+'.lastword.'\s\+@\?\zs.*\ze'."\n")

				call IMAP_Debug('getting abbreviationRHS = ['.abbreviationRHS.']', 'imap')

				if @a =~ "No abbreviation found" || abbreviationRHS == ""
					let @a = _a
					return a:char
				endif

				let @a = _a
				let abbreviationRHS = escape(abbreviationRHS, '\<"')
				exec 'let abbreviationRHS = "'.abbreviationRHS.'"'

				let lhs = lastword.a:char
				let rhs = abbreviationRHS.a:char
				let phs = IMAP_GetPlaceHolderStart()
				let phe = IMAP_GetPlaceHolderEnd()
			else
				return a:char
			endif
		else
			return a:char
		endif
	endif
	" Find the longest left-hand side that matches the line so far.
	" matchstr() returns the match that starts first. This automatically
	" ensures that the longest LHS is used for the mapping.
	if !exists('lhs') || !exists('rhs')
		let lhs = matchstr(text, "\\C\\V\\(" . s:LHS_{ft}_{charHash} . "\\)\\$")
		let hash = s:Hash(lhs)
		let rhs = s:Map_{ft}_{hash}
		let phs = s:phs_{ft}_{hash} 
		let phe = s:phe_{ft}_{hash}
		let skel = s:skel_{ft}_{hash}
	endif

	if strlen(lhs) == 0
		return a:char
	endif
	" enough back-spaces to erase the left-hand side; -1 for the last
	" character typed:
	let bs = substitute(strpart(lhs, 1), ".", "\<bs>", "g")
	return bs . IMAP_PutTextWithMovement(rhs, phs, phe, skel)
endfunction

" }}}
" IMAP_PutTextWithMovement: returns the string with movement appended {{{
" Description:
"   If a:str contains "placeholders", then appends movement commands to
"   str in a way that the user moves to the first placeholder and enters
"   insert or select mode. If supplied with 2 additional arguments, then
"   they are assumed to be the placeholder specs. Otherwise, they are
"   assumed to be '<+' and '+>'. These placeholder chars are replaced
"   with the users settings of [bg]:Imap_PlaceHolderStart and
"   [bg]:Imap_PlaceHolderEnd.
function! IMAP_PutTextWithMovement(str, ...)

	let skel = 0

	" The placeholders used in the particular input string. These can be
	" different from what the user wants to use.
	if a:0 < 2
		let phs = '<+'
		let phe = '+>'
	else
		let phs = escape(a:1, '\')
		let phe = escape(a:2, '\')
		if exists('a:3') && 0 != a:3
			let skel = 1
		endif
	endif

	if has('ruby')

		ruby << EOF

		require 'erb'

		text = nil

		if 0 != VIM::evaluate('skel').to_i

			skel_name = VIM::evaluate('a:str')
			skel_dir = VIM::evaluate('g:yasnippets_skeletons')

			skel = File.join(skel_dir, skel_name)

			text = File.read(skel) if File.readable?(skel)

		else

			text = VIM::evaluate('a:str')

		end

		if text

			text = ERB.new(text, nil, '-').result
			text.gsub!(/["]/, '\\\1')

			VIM::command("let text = \"#{text}\"")

		end
EOF

        if !exists('text')
			return ''
		end

    else
		let text = a:str
	endif

	" The user's placeholder settings.
	let phsUser = IMAP_GetPlaceHolderStart()
	let pheUser = IMAP_GetPlaceHolderEnd()

	" Problem:  depending on the setting of the 'encoding' option, a character
	" such as "\xab" may not match itself.  We try to get around this by
	" changing the encoding of all our strings.  At the end, we have to
	" convert text back.
	let phsEnc     = s:Iconv(phs, "encode")
	let pheEnc     = s:Iconv(phe, "encode")
	let phsUserEnc = s:Iconv(phsUser, "encode")
	let pheUserEnc = s:Iconv(pheUser, "encode")
	let textEnc    = s:Iconv(text, "encode")
	if textEnc != text
		let textEncoded = 1
	else
		let textEncoded = 0
	endif

	let pattern = '\V\(\.\{-}\)' .phs. '\(\.\{-}\)' .phe. '\(\.\*\)'
	" If there are no placeholders, just return the text.
	if textEnc !~ pattern
		call IMAP_Debug('Not getting '.phs.' and '.phe.' in '.textEnc, 'imap')
		return text
	endif
	" Break text up into "initial <+template+> final"; any piece may be empty.
	let initialEnc  = substitute(textEnc, pattern, '\1', '')
	let templateEnc = substitute(textEnc, pattern, '\2', '')
	let finalEnc    = substitute(textEnc, pattern, '\3', '')

	" If the user does not want to use placeholders, then remove all but the
	" first placeholder.
	" Otherwise, replace all occurences of the placeholders here with the
	" user's choice of placeholder settings.
	if exists('g:Imap_UsePlaceHolders') && !g:Imap_UsePlaceHolders
		let finalEnc = substitute(finalEnc, '\V'.phs.'\.\{-}'.phe, '', 'g')
	else
		let finalEnc = substitute(finalEnc, '\V'.phs.'\(\.\{-}\)'.phe,
					\ phsUserEnc.'\1'.pheUserEnc, 'g')
	endif

	" The substitutions are done, so convert back, if necessary.
	if textEncoded
		let initial = s:Iconv(initialEnc, "decode")
		let template = s:Iconv(templateEnc, "decode")
		let final = s:Iconv(finalEnc, "decode")
	else
		let initial = initialEnc
		let template = templateEnc
		let final = finalEnc
	endif

	" Build up the text to insert:
	" 1. the initial text plus an extra character;
	" 2. go to Normal mode with <C-\><C-N>, so it works even if 'insertmode'
	" is set, and mark the position;
	" 3. replace the extra character with tamplate and final;
	" 4. back to Normal mode and restore the cursor position;
	" 5. call IMAP_Jumpfunc().
	let template = phsUser . template . pheUser
	" Old trick:  insert and delete a character to get the same behavior at
	" start, middle, or end of line and on empty lines.
	let text = initial . "X\<C-\>\<C-N>:call IMAP_Mark('set')\<CR>\"_s"
	let text = text . template . final
	let text = text . "\<C-\>\<C-N>:call IMAP_Mark('go')\<CR>"
	let text = text . "i\<C-r>=IMAP_Jumpfunc('', 1)\<CR>"

	call IMAP_Debug('IMAP_PutTextWithMovement: text = ['.text.']', 'imap')
	return text
endfunction

" }}}
" IMAP_Jumpfunc: takes user to next <+place-holder+> {{{
" Author: Luc Hermitte
" Arguments:
" direction: flag for the search() function. If set to '', search forwards,
"            if 'b', then search backwards. See the {flags} argument of the
"            |search()| function for valid values.
" inclusive: In vim, the search() function is 'exclusive', i.e we always goto
"            next cursor match even if there is a match starting from the
"            current cursor position. Setting this argument to 1 makes
"            IMAP_Jumpfunc() also respect a match at the current cursor
"            position. 'inclusive'ness is necessary for IMAP() because a
"            placeholder string can occur at the very beginning of a map which
"            we want to select.
"            We use a non-zero value only in special conditions. Most mappings
"            should use a zero value.
function! IMAP_Jumpfunc(direction, inclusive)

	" The user's placeholder settings.
	let phsUser = IMAP_GetPlaceHolderStart()
	let pheUser = IMAP_GetPlaceHolderEnd()

	let searchString = ''
	" If this is not an inclusive search or if it is inclusive, but the
	" current cursor position does not contain a placeholder character, then
	" search for the placeholder characters.
	if !a:inclusive || strpart(getline('.'), col('.')-1) !~ '\V\^'.phsUser
		let searchString = '\V'.phsUser.'\_.\{-}'.pheUser
	endif

	" If we didn't find any placeholders return quietly.
	if searchString != '' && !search(searchString, a:direction)
		return ''
	endif

	" Open any closed folds and make this part of the text visible.
	silent! foldopen!

	" Calculate if we have an empty placeholder or if it contains some
	" description.
	let template = 
		\ matchstr(strpart(getline('.'), col('.')-1),
		\          '\V\^'.phsUser.'\zs\.\{-}\ze\('.pheUser.'\|\$\)')
	let placeHolderEmpty = !strlen(template)

	" If we are selecting in exclusive mode, then we need to move one step to
	" the right
	let extramove = ''
	if &selection == 'exclusive'
		let extramove = 'l'
	endif

	" Select till the end placeholder character.
	let movement = "\<C-o>v/\\V".pheUser."/e\<CR>".extramove

	" First remember what the search pattern was. s:RemoveLastHistoryItem will
	" reset @/ to this pattern so we do not create new highlighting.
	let g:Tex_LastSearchPattern = @/

	" Now either goto insert mode or select mode.
	if placeHolderEmpty && g:Imap_DeleteEmptyPlaceHolders
		" delete the empty placeholder into the blackhole.
		return movement."\"_c\<C-o>:".s:RemoveLastHistoryItem."\<CR>"
	else
		return movement."\<C-\>\<C-N>:".s:RemoveLastHistoryItem."\<CR>gv\<C-g>"
	endif
	
endfunction

" }}}
" Maps for IMAP_Jumpfunc {{{
"
" These mappings use <Plug> and thus provide for easy user customization. When
" the user wants to map some other key to jump forward, he can do for
" instance:
"   nmap ,f   <plug>IMAP_JumpForward
" etc.

" jumping forward and back in insert mode.
imap <silent> <Plug>IMAP_JumpForward    <c-r>=IMAP_Jumpfunc('', 0)<CR>
imap <silent> <Plug>IMAP_JumpBack       <c-r>=IMAP_Jumpfunc('b', 0)<CR>

" jumping in normal mode
nmap <silent> <Plug>IMAP_JumpForward        i<c-r>=IMAP_Jumpfunc('', 0)<CR>
nmap <silent> <Plug>IMAP_JumpBack           i<c-r>=IMAP_Jumpfunc('b', 0)<CR>

" deleting the present selection and then jumping forward.
vmap <silent> <Plug>IMAP_DeleteAndJumpForward       "_<Del>i<c-r>=IMAP_Jumpfunc('', 0)<CR>
vmap <silent> <Plug>IMAP_DeleteAndJumpBack          "_<Del>i<c-r>=IMAP_Jumpfunc('b', 0)<CR>

" jumping forward without deleting present selection.
vmap <silent> <Plug>IMAP_JumpForward       <C-\><C-N>i<c-r>=IMAP_Jumpfunc('', 0)<CR>
vmap <silent> <Plug>IMAP_JumpBack          <C-\><C-N>`<i<c-r>=IMAP_Jumpfunc('b', 0)<CR>

" }}}
" Default maps for IMAP_Jumpfunc {{{
" map only if there is no mapping already. allows for user customization.
" NOTE: Default mappings for jumping to the previous placeholder are not
"       provided. It is assumed that if the user will create such mappings
"       hself if e so desires.
if !hasmapto('<Plug>IMAP_JumpForward', 'i')
    imap <C-J> <Plug>IMAP_JumpForward
endif
if !hasmapto('<Plug>IMAP_JumpForward', 'n')
    nmap <C-J> <Plug>IMAP_JumpForward
endif
if exists('g:Imap_StickyPlaceHolders') && g:Imap_StickyPlaceHolders
	if !hasmapto('<Plug>IMAP_JumpForward', 'v')
		vmap <C-J> <Plug>IMAP_JumpForward
	endif
else
	if !hasmapto('<Plug>IMAP_DeleteAndJumpForward', 'v')
		vmap <C-J> <Plug>IMAP_DeleteAndJumpForward
	endif
endif
" }}}

nmap <silent> <script> <plug><+SelectRegion+> `<v`>

" ============================================================================== 
" helper functions
" ============================================================================== 
" s:RemoveLastHistoryItem: removes last search item from search history {{{
" Description: Execute this string to clean up the search history.
let s:RemoveLastHistoryItem = ':call histdel("/", -1)|let @/=g:Tex_LastSearchPattern'

" }}}
" s:Hash: Return a version of a string that can be used as part of a variable" {{{
" name.
" 	Converts every non alphanumeric character into _{ascii}_ where {ascii} is
" 	the ASCII code for that character...
fun! s:Hash(text)
	return substitute(a:text, '\([^[:alnum:]]\)',
				\ '\="_".char2nr(submatch(1))."_"', 'g')
endfun
"" }}}
" IMAP_GetPlaceHolderStart and IMAP_GetPlaceHolderEnd:  "{{{
" return the buffer local placeholder variables, or the global one, or the default.
function! IMAP_GetPlaceHolderStart()
	if exists("b:Imap_PlaceHolderStart") && strlen(b:Imap_PlaceHolderEnd)
		return b:Imap_PlaceHolderStart
	elseif exists("g:Imap_PlaceHolderStart") && strlen(g:Imap_PlaceHolderEnd)
		return g:Imap_PlaceHolderStart
	else
		return "<+"
endfun
function! IMAP_GetPlaceHolderEnd()
	if exists("b:Imap_PlaceHolderEnd") && strlen(b:Imap_PlaceHolderEnd)
		return b:Imap_PlaceHolderEnd
	elseif exists("g:Imap_PlaceHolderEnd") && strlen(g:Imap_PlaceHolderEnd)
		return g:Imap_PlaceHolderEnd
	else
		return "+>"
endfun
" }}}
" s:Iconv:  a wrapper for iconv()" {{{
" Problem:  after
" 	let text = "\xab"
" (or using the raw 8-bit ASCII character in a file with 'fenc' set to
" "latin1") if 'encoding' is set to utf-8, then text does not match itself:
" 	echo text =~ text
" returns 0.
" Solution:  When this happens, a re-encoded version of text does match text:
" 	echo iconv(text, "latin1", "utf8") =~ text
" returns 1.  In this case, convert text to utf-8 with iconv().
" TODO:  Is it better to use &encoding instead of "utf8"?  Internally, vim
" uses utf-8, and can convert between latin1 and utf-8 even when compiled with
" -iconv, so let's try using utf-8.
" Arguments:
" 	a:text = text to be encoded or decoded
" 	a:mode = "encode" (latin1 to utf8) or "decode" (utf8 to latin1)
" Caution:  do not encode and then decode without checking whether the text
" has changed, becuase of the :if clause in encoding!
function! s:Iconv(text, mode)
	if a:mode == "decode"
		return iconv(a:text, "utf8", "latin1")
	endif
	if a:text =~ '\V\^' . escape(a:text, '\') . '\$'
		return a:text
	endif
	let textEnc = iconv(a:text, "latin1", "utf8")
	if textEnc !~ '\V\^' . escape(a:text, '\') . '\$'
		call IMAP_Debug('Encoding problems with text '.a:text.' ', 'imap')
	endif
	return textEnc
endfun
"" }}}
" IMAP_Debug: interface to Tex_Debug if available, otherwise emulate it {{{
" Description: 
" Do not want a memory leak! Set this to zero so that imaps always
" starts out in a non-debugging mode.
if !exists('g:Imap_Debug')
	let g:Imap_Debug = 0
endif
function! IMAP_Debug(string, pattern)
	if !g:Imap_Debug
		return
	endif
	if exists('*Tex_Debug')
		call Tex_Debug(a:string, a:pattern)
	else
		if !exists('s:debug_'.a:pattern)
			let s:debug_{a:pattern} = a:string
		else
			let s:debug_{a:pattern} = s:debug_{a:pattern}.a:string
		endif
	endif
endfunction " }}}
" IMAP_DebugClear: interface to Tex_DebugClear if avaialable, otherwise emulate it {{{
" Description: 
function! IMAP_DebugClear(pattern)
	if exists('*Tex_DebugClear')
		call Tex_DebugClear(a:pattern)
	else	
		let s:debug_{a:pattern} = ''
	endif
endfunction " }}}
" IMAP_PrintDebug: interface to Tex_DebugPrint if avaialable, otherwise emulate it {{{
" Description: 
function! IMAP_PrintDebug(pattern)
	if exists('*Tex_PrintDebug')
		call Tex_PrintDebug(a:pattern)
	else
		if exists('s:debug_'.a:pattern)
			echo s:debug_{a:pattern}
		endif
	endif
endfunction " }}}
" IMAP_Mark:  Save the cursor position (if a:action == 'set') in a" {{{
" script-local variable; restore this position if a:action == 'go'.
let s:Mark = "(0,0)"
let s:initBlanks = ''
function! IMAP_Mark(action)
	if a:action == 'set'
		let s:Mark = "(" . line(".") . "," . col(".") . ")"
		let s:initBlanks = matchstr(getline('.'), '^\s*')
	elseif a:action == 'go'
		execute "call cursor" s:Mark
		let blanksNow = matchstr(getline('.'), '^\s*')
		if strlen(blanksNow) > strlen(s:initBlanks)
			execute 'silent! normal! '.(strlen(blanksNow) - strlen(s:initBlanks)).'l'
		elseif strlen(blanksNow) < strlen(s:initBlanks)
			execute 'silent! normal! '.(strlen(s:initBlanks) - strlen(blanksNow)).'h'
		endif
	endif
endfunction	"" }}}
" IMAP_GetVal: gets the value of a variable {{{
" Description: first checks window local, then buffer local etc.
function! IMAP_GetVal(name, ...)
	if a:0 > 0
		let default = a:1
	else
		let default = ''
	endif
	if exists('w:'.a:name)
		return w:{a:name}
	elseif exists('b:'.a:name)
		return b:{a:name}
	elseif exists('g:'.a:name)
		return g:{a:name}
	else
		return default
	endif
endfunction " }}}

" }}}

let &cpo = s:save_cpo

" vim:ft=vim:ts=4:sw=4:noet:fdm=marker:commentstring=\"\ %s:nowrap
