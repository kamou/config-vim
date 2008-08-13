" Align: tool to align multiple fields based on one or more separators
"   Author:		Charles E. Campbell, Jr.
"   Date:		Mar 06, 2008
"   Version:	33
" GetLatestVimScripts: 294 1 :AutoInstall: Align.vim
" GetLatestVimScripts: 1066 1 :AutoInstall: cecutil.vim
" Copyright:    Copyright (C) 1999-2007 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               Align.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
" Romans 1:16,17a : For I am not ashamed of the gospel of Christ, for it is {{{1
" the power of God for salvation for everyone who believes; for the Jew first,
" and also for the Greek.  For in it is revealed God's righteousness from
" faith to faith.

" ---------------------------------------------------------------------
" Load Once: {{{1
if exists("g:loaded_align") || &cp
 finish
endif
let g:loaded_align = "v33"
let s:keepcpo      = &cpo
set cpo&vim
"DechoTabOn

" ---------------------------------------------------------------------
" Debugging Support:
"if !exists("g:loaded_Decho") "Decho
" runtime plugin/Decho.vim
"endif	" Decho

" ---------------------------------------------------------------------
" AlignCtrl: enter alignment patterns here {{{1
"
"   Styles   =  all alignment-break patterns are equivalent
"            C  cycle through alignment-break pattern(s)
"            l  left-justified alignment
"            r  right-justified alignment
"            c  center alignment
"            -  skip separator, treat as part of field
"            :  treat rest of line as field
"            +  repeat previous [lrc] style
"            <  left justify separators
"            >  right justify separators
"            |  center separators
"
"   Builds   =  s:AlignPat  s:AlignCtrl  s:AlignPatQty
"            C  s:AlignPat  s:AlignCtrl  s:AlignPatQty
"            p  s:AlignPrePad
"            P  s:AlignPostPad
"            w  s:AlignLeadKeep
"            W  s:AlignLeadKeep
"            I  s:AlignLeadKeep
"            l  s:AlignStyle
"            r  s:AlignStyle
"            -  s:AlignStyle
"            +  s:AlignStyle
"            :  s:AlignStyle
"            c  s:AlignStyle
"            g  s:AlignGPat
"            v  s:AlignVPat
"            <  s:AlignSep
"            >  s:AlignSep
"            |  s:AlignSep
fun! Align#AlignCtrl(...)

"  call Dfunc("AlignCtrl(...) a:0=".a:0)

  " save options that will be changed
  let keep_search = @/
  let keep_ic     = &ic

  " turn ignorecase off
  set noic

  " clear visual mode so that old visual-mode selections don't
  " get applied to new invocations of Align().
  if v:version < 602
   if !exists("s:Align_gavemsg")
	let s:Align_gavemsg= 1
    echomsg "Align needs at least Vim version 6.2 to clear visual-mode selection"
   endif
  elseif exists("s:dovisclear")
"   call Decho("clearing visual mode a:0=".a:0." a:1<".a:1.">")
   let clearvmode= visualmode(1)
  endif

  " set up a list akin to an argument list
  if a:0 > 0
   let A= s:QArgSplitter(a:1)
  else
   let A=[0]
  endif

  if A[0] > 0
   let style = A[1]

   " Check for bad separator patterns (zero-length matches)
   " (but zero-length patterns for g/v is ok)
   if style !~# '[gv]'
    let ipat= 2
    while ipat <= A[0]
     if "" =~ A[ipat]
      echoerr "AlignCtrl: separator<".A[ipat]."> matches zero-length string"
	  let &ic= keep_ic
"      call Dret("AlignCtrl")
      return
     endif
     let ipat= ipat + 1
    endwhile
   endif
  endif

"  call Decho("AlignCtrl() A[0]=".A[0])
  if !exists("s:AlignStyle")
   let s:AlignStyle= "l"
  endif
  if !exists("s:AlignPrePad")
   let s:AlignPrePad= 0
  endif
  if !exists("s:AlignPostPad")
   let s:AlignPostPad= 0
  endif
  if !exists("s:AlignLeadKeep")
   let s:AlignLeadKeep= 'w'
  endif

  if A[0] == 0
   " ----------------------
   " List current selection
   " ----------------------
   echo "AlignCtrl<".s:AlignCtrl."> qty=".s:AlignPatQty." AlignStyle<".s:AlignStyle."> Padding<".s:AlignPrePad."|".s:AlignPostPad."> LeadingWS=".s:AlignLeadKeep." AlignSep=".s:AlignSep
"   call Decho("AlignCtrl<".s:AlignCtrl."> qty=".s:AlignPatQty." AlignStyle<".s:AlignStyle."> Padding<".s:AlignPrePad."|".s:AlignPostPad."> LeadingWS=".s:AlignLeadKeep." AlignSep=".s:AlignSep)
   if      exists("s:AlignGPat") && !exists("s:AlignVPat")
	echo "AlignGPat<".s:AlignGPat.">"
   elseif !exists("s:AlignGPat") &&  exists("s:AlignVPat")
	echo "AlignVPat<".s:AlignVPat.">"
   elseif exists("s:AlignGPat") &&  exists("s:AlignVPat")
	echo "AlignGPat<".s:AlignGPat."> AlignVPat<".s:AlignVPat.">"
   endif
   let ipat= 1
   while ipat <= s:AlignPatQty
	echo "Pat".ipat."<".s:AlignPat_{ipat}.">"
"	call Decho("Pat".ipat."<".s:AlignPat_{ipat}.">")
	let ipat= ipat + 1
   endwhile

  else
   " ----------------------------------
   " Process alignment control settings
   " ----------------------------------
"   call Decho("process the alignctrl settings")
"   call Decho("style<".style.">")

   if style ==? "default"
     " Default:  preserve initial leading whitespace, left-justified,
     "           alignment on '=', one space padding on both sides
	 if exists("s:AlignCtrlStackQty")
	  " clear AlignCtrl stack
      while s:AlignCtrlStackQty > 0
	   call Align#AlignPop()
	  endwhile
	  unlet s:AlignCtrlStackQty
	 endif
	 " Set AlignCtrl to its default value
     call Align#AlignCtrl("Ilp1P1=<",'=')
	 call Align#AlignCtrl("g")
	 call Align#AlignCtrl("v")
	 let s:dovisclear = 1
	 let &ic          = keep_ic
	 let @/           = keep_search
"     call Dret("AlignCtrl")
	 return
   endif

   if style =~# 'm'
	" map support: Do an AlignPush now and the next call to Align()
	"              will do an AlignPop at exit
"	call Decho("style case m: do AlignPush")
	call Align#AlignPush()
	let s:DoAlignPop= 1
   endif

   " = : record a list of alignment patterns that are equivalent
   if style =~# "="
"	call Decho("style case =: record list of equiv alignment patterns")
    let s:AlignCtrl  = '='
	if A[0] >= 2
     let s:AlignPatQty= 1
     let s:AlignPat_1 = A[2]
     let ipat         = 3
     while ipat <= A[0]
      let s:AlignPat_1 = s:AlignPat_1.'\|'.A[ipat]
      let ipat         = ipat + 1
     endwhile
     let s:AlignPat_1= '\('.s:AlignPat_1.'\)'
"     call Decho("AlignCtrl<".s:AlignCtrl."> AlignPat<".s:AlignPat_1.">")
	endif

    "c : cycle through alignment pattern(s)
   elseif style =~# 'C'
"	call Decho("style case C: cycle through alignment pattern(s)")
    let s:AlignCtrl  = 'C'
	if A[0] >= 2
     let s:AlignPatQty= A[0] - 1
     let ipat         = 1
     while ipat < A[0]
      let s:AlignPat_{ipat}= A[ipat+1]
"     call Decho("AlignCtrl<".s:AlignCtrl."> AlignQty=".s:AlignPatQty." AlignPat_".ipat."<".s:AlignPat_{ipat}.">")
      let ipat= ipat + 1
     endwhile
	endif
   endif

   if style =~# 'p'
    let s:AlignPrePad= substitute(style,'^.*p\(\d\+\).*$','\1','')
"	call Decho("style case p".s:AlignPrePad.": pre-separator padding")
    if s:AlignPrePad == ""
     echoerr "AlignCtrl: 'p' needs to be followed by a numeric argument'
     let @/ = keep_search
	 let &ic= keep_ic
"     call Dret("AlignCtrl")
     return
	endif
   endif

   if style =~# 'P'
    let s:AlignPostPad= substitute(style,'^.*P\(\d\+\).*$','\1','')
"	call Decho("style case P".s:AlignPostPad.": post-separator padding")
    if s:AlignPostPad == ""
     echoerr "AlignCtrl: 'P' needs to be followed by a numeric argument'
     let @/ = keep_search
	 let &ic= keep_ic
"     call Dret("AlignCtrl")
     return
	endif
   endif

   if     style =~# 'w'
"	call Decho("style case w: ignore leading whitespace")
	let s:AlignLeadKeep= 'w'
   elseif style =~# 'W'
"	call Decho("style case w: keep leading whitespace")
	let s:AlignLeadKeep= 'W'
   elseif style =~# 'I'
"	call Decho("style case w: retain initial leading whitespace")
	let s:AlignLeadKeep= 'I'
   endif

   if style =~# 'g'
	" first list item is a "g" selector pattern
"	call Decho("style case g: global selector pattern")
	if A[0] < 2
	 if exists("s:AlignGPat")
	  unlet s:AlignGPat
"	  call Decho("unlet s:AlignGPat")
	 endif
	else
	 let s:AlignGPat= A[2]
"	 call Decho("s:AlignGPat<".s:AlignGPat.">")
	endif
   elseif style =~# 'v'
	" first list item is a "v" selector pattern
"	call Decho("style case v: global selector anti-pattern")
	if A[0] < 2
	 if exists("s:AlignVPat")
	  unlet s:AlignVPat
"	  call Decho("unlet s:AlignVPat")
	 endif
	else
	 let s:AlignVPat= A[2]
"	 call Decho("s:AlignVPat<".s:AlignVPat.">")
	endif
   endif

    "[-lrc+:] : set up s:AlignStyle
   if style =~# '[-lrc+:]'
"	call Decho("style case [-lrc+:]: field justification")
    let s:AlignStyle= substitute(style,'[^-lrc:+]','','g')
"    call Decho("AlignStyle<".s:AlignStyle.">")
   endif

   "[<>|] : set up s:AlignSep
   if style =~# '[<>|]'
"	call Decho("style case [-lrc+:]: separator justification")
	let s:AlignSep= substitute(style,'[^<>|]','','g')
"	call Decho("AlignSep ".s:AlignSep)
   endif
  endif

  " sanity
  if !exists("s:AlignCtrl")
   let s:AlignCtrl= '='
  endif

  " restore search and options
  let @/ = keep_search
  let &ic= keep_ic

"  call Dret("AlignCtrl ".s:AlignCtrl.'p'.s:AlignPrePad.'P'.s:AlignPostPad.s:AlignLeadKeep.s:AlignStyle)
  return s:AlignCtrl.'p'.s:AlignPrePad.'P'.s:AlignPostPad.s:AlignLeadKeep.s:AlignStyle
endfun

" ---------------------------------------------------------------------
" MakeSpace: returns a string with spacecnt blanks {{{1
fun! s:MakeSpace(spacecnt)
"  call Dfunc("MakeSpace(spacecnt=".a:spacecnt.")")
  let str      = ""
  let spacecnt = a:spacecnt
  while spacecnt > 0
   let str      = str . " "
   let spacecnt = spacecnt - 1
  endwhile
"  call Dret("MakeSpace <".str.">")
  return str
endfun

" ---------------------------------------------------------------------
" Align#Align: align selected text based on alignment pattern(s) {{{1
fun! Align#Align(hasctrl,...) range
"  call Dfunc("Align#Align(hasctrl=".a:hasctrl.",...) a:0=".a:0)

  " sanity check
  if string(a:hasctrl) != "0" && string(a:hasctrl) != "1"
   echohl Error|echo 'usage: Align#Align(hasctrl<'.a:hasctrl.'> (should be 0 or 1),"separator(s)"  (you have '.a:0.') )'|echohl None
"   call Dret("Align#Align")
   return
  endif

  " set up a list akin to an argument list
  if a:0 > 0
   let A= s:QArgSplitter(a:1)
  else
   let A=[0]
  endif

  " if :Align! was used, then the first argument is (should be!) an AlignCtrl string
  " Note that any alignment control set this way will be temporary.
  let hasctrl= a:hasctrl
"  call Decho("hasctrl=".hasctrl)
  if a:hasctrl && A[0] >= 1
"   call Decho("Align! : using A[1]<".A[1]."> for AlignCtrl")
   if A[1] =~ '[gv]'
   	let hasctrl= hasctrl + 1
	call Align#AlignCtrl('m')
    call Align#AlignCtrl(A[1],A[2])
"    call Decho("Align! : also using A[2]<".A[2]."> for AlignCtrl")
   elseif A[1] !~ 'm'
    call Align#AlignCtrl(A[1]."m")
   else
    call Align#AlignCtrl(A[1])
   endif
  endif

  " Check for bad separator patterns (zero-length matches)
  let ipat= 1 + hasctrl
  while ipat <= A[0]
   if "" =~ A[ipat]
	echoerr "Align: separator<".A[ipat]."> matches zero-length string"
"    call Dret("Align#Align")
	return
   endif
   let ipat= ipat + 1
  endwhile

  " record current search pattern for subsequent restoration
  let keep_search= @/
  let keep_ic    = &ic
  let keep_report= &report
  set noic report=10000

  if A[0] > hasctrl
  " Align will accept a list of separator regexps
"   call Decho("A[0]=".A[0].": accepting list of separator regexp")

   if s:AlignCtrl =~# "="
   	"= : consider all separators to be equivalent
"    call Decho("AlignCtrl: record list of equivalent alignment patterns")
    let s:AlignCtrl  = '='
    let s:AlignPat_1 = A[1 + hasctrl]
    let s:AlignPatQty= 1
    let ipat         = 2 + hasctrl
    while ipat <= A[0]
     let s:AlignPat_1 = s:AlignPat_1.'\|'.A[ipat]
     let ipat         = ipat + 1
    endwhile
    let s:AlignPat_1= '\('.s:AlignPat_1.'\)'
"    call Decho("AlignCtrl<".s:AlignCtrl."> AlignPat<".s:AlignPat_1.">")

   elseif s:AlignCtrl =~# 'C'
    "c : cycle through alignment pattern(s)
"    call Decho("AlignCtrl: cycle through alignment pattern(s)")
    let s:AlignCtrl  = 'C'
    let s:AlignPatQty= A[0] - hasctrl
    let ipat         = 1
    while ipat <= s:AlignPatQty
     let s:AlignPat_{ipat}= A[(ipat + hasctrl)]
"     call Decho("AlignCtrl<".s:AlignCtrl."> AlignQty=".s:AlignPatQty." AlignPat_".ipat."<".s:AlignPat_{ipat}.">")
     let ipat= ipat + 1
    endwhile
   endif
  endif

  " Initialize so that begline<endline and begcol<endcol.
  " Ragged right: check if the column associated with '< or '>
  "               is greater than the line's string length -> ragged right.
  " Have to be careful about visualmode() -- it returns the last visual
  " mode used whether or not it was used currently.
  let begcol   = virtcol("'<")-1
  let endcol   = virtcol("'>")-1
  if begcol > endcol
   let begcol  = virtcol("'>")-1
   let endcol  = virtcol("'<")-1
  endif
"  call Decho("begcol=".begcol." endcol=".endcol)
  let begline  = a:firstline
  let endline  = a:lastline
  if begline > endline
   let begline = a:lastline
   let endline = a:firstline
  endif
"  call Decho("begline=".begline." endline=".endline)
  let fieldcnt = 0
  if (begline == line("'>") && endline == line("'<")) || (begline == line("'<") && endline == line("'>"))
   let vmode= visualmode()
"   call Decho("vmode=".vmode)
   if vmode == "\<c-v>"
	if exists("g:Align_xstrlen") && g:Align_xstrlen
     let ragged   = ( col("'>") > s:Strlen(getline("'>")) || col("'<") > s:Strlen(getline("'<")) )
	else
     let ragged   = ( col("'>") > strlen(getline("'>")) || col("'<") > strlen(getline("'<")) )
	endif
   else
	let ragged= 1
   endif
  else
   let ragged= 1
  endif
  if ragged
   let begcol= 0
  endif
"  call Decho("lines[".begline.",".endline."] col[".begcol.",".endcol."] ragged=".ragged." AlignCtrl<".s:AlignCtrl.">")

  " Keep user options
  let etkeep   = &et
  let pastekeep= &paste
  setlocal et paste

  " convert selected range of lines to use spaces instead of tabs
  " but if first line's initial white spaces are to be retained
  " then use 'em
  if begcol <= 0 && s:AlignLeadKeep == 'I'
   " retain first leading whitespace for all subsequent lines
   let bgntxt= substitute(getline(begline),'^\(\s*\).\{-}$','\1','')
"   call Decho("retaining 1st leading whitespace: bgntxt<".bgntxt.">")
   set noet
  endif
  exe begline.",".endline."ret"

  " Execute two passes
  " First  pass: collect alignment data (max field sizes)
  " Second pass: perform alignment
  let pass= 1
  while pass <= 2
"   call Decho(" ")
"   call Decho("---- Pass ".pass.": ----")

   let line= begline
   while line <= endline
    " Process each line
    let txt = getline(line)
"    call Decho(" ")
"    call Decho("Pass".pass.": Line ".line." <".txt.">")

    " AlignGPat support: allows a selector pattern (akin to g/selector/cmd )
    if exists("s:AlignGPat")
"	 call Decho("Pass".pass.": AlignGPat<".s:AlignGPat.">")
	 if match(txt,s:AlignGPat) == -1
"	  call Decho("Pass".pass.": skipping")
	  let line= line + 1
	  continue
	 endif
    endif

    " AlignVPat support: allows a selector pattern (akin to v/selector/cmd )
    if exists("s:AlignVPat")
"	 call Decho("Pass".pass.": AlignVPat<".s:AlignVPat.">")
	 if match(txt,s:AlignVPat) != -1
"	  call Decho("Pass".pass.": skipping")
	  let line= line + 1
	  continue
	 endif
    endif

	" Always skip blank lines
	if match(txt,'^\s*$') != -1
"	  call Decho("Pass".pass.": skipping")
	 let line= line + 1
	 continue
	endif

    " Extract visual-block selected text (init bgntxt, endtxt)
	if exists("g:Align_xstrlen") && g:Align_xstrlen
     let txtlen= s:Strlen(txt)
	else
     let txtlen= strlen(txt)
	endif
    if begcol > 0
	 " Record text to left of selected area
     let bgntxt= strpart(txt,0,begcol)
"	  call Decho("Pass".pass.": record text to left: bgntxt<".bgntxt.">")
    elseif s:AlignLeadKeep == 'W'
	 let bgntxt= substitute(txt,'^\(\s*\).\{-}$','\1','')
"	  call Decho("Pass".pass.": retaining all leading ws: bgntxt<".bgntxt.">")
    elseif s:AlignLeadKeep == 'w' || !exists("bgntxt")
	 " No beginning text
	 let bgntxt= ""
"	  call Decho("Pass".pass.": no beginning text")
    endif
    if ragged
	 let endtxt= ""
    else
     " Elide any text lying outside selected columnar region
     let endtxt= strpart(txt,endcol+1,txtlen-endcol)
     let txt   = strpart(txt,begcol,endcol-begcol+1)
    endif
"    call Decho(" ")
"    call Decho("Pass".pass.": bgntxt<".bgntxt.">")
"    call Decho("Pass".pass.":    txt<". txt  .">")
"    call Decho("Pass".pass.": endtxt<".endtxt.">")
	if !exists("s:AlignPat_{1}")
	 echohl Error|echo "no separators specified!"|echohl None
"     call Dret("Align#Align")
	 return
	endif

    " Initialize for both passes
    let seppat      = s:AlignPat_{1}
    let ifield      = 1
    let ipat        = 1
    let bgnfield    = 0
    let endfield    = 0
    let alignstyle  = s:AlignStyle
    let doend       = 1
	let newtxt      = ""
    let alignprepad = s:AlignPrePad
    let alignpostpad= s:AlignPostPad
	let alignsep    = s:AlignSep
	let alignophold = " "
	let alignop     = "l"
"	call Decho("Pass".pass.": initial alignstyle<".alignstyle."> seppat<".seppat.">")

    " Process each field on the line
    while doend > 0

	  " C-style: cycle through pattern(s)
     if s:AlignCtrl == 'C' && doend == 1
	  let seppat   = s:AlignPat_{ipat}
"	  call Decho("Pass".pass.": processing field: AlignCtrl=".s:AlignCtrl." ipat=".ipat." seppat<".seppat.">")
	  let ipat     = ipat + 1
	  if ipat > s:AlignPatQty
	   let ipat = 1
	  endif
     endif

	 " cyclic alignment/justification operator handling
	 let alignophold  = alignop
	 let alignop      = strpart(alignstyle,0,1)
	 if alignop == '+' || doend == 2
	  let alignop= alignophold
	 else
	  let alignstyle   = strpart(alignstyle,1).strpart(alignstyle,0,1)
	  let alignopnxt   = strpart(alignstyle,0,1)
	  if alignop == ':'
	   let seppat  = '$'
	   let doend   = 2
"	   call Decho("Pass".pass.": alignop<:> case: setting seppat<$> doend==2")
	  endif
	 endif

	 " cylic separator alignment specification handling
	 let alignsepop= strpart(alignsep,0,1)
	 let alignsep  = strpart(alignsep,1).alignsepop

	 " mark end-of-field and the subsequent end-of-separator.
	 " Extend field if alignop is '-'
     let endfield = match(txt,seppat,bgnfield)
	 let sepfield = matchend(txt,seppat,bgnfield)
     let skipfield= sepfield
"	 call Decho("Pass".pass.": endfield=match(txt<".txt.">,seppat<".seppat.">,bgnfield=".bgnfield.")=".endfield)
	 while alignop == '-' && endfield != -1
	  let endfield  = match(txt,seppat,skipfield)
	  let sepfield  = matchend(txt,seppat,skipfield)
	  let skipfield = sepfield
	  let alignop   = strpart(alignstyle,0,1)
	  let alignstyle= strpart(alignstyle,1).strpart(alignstyle,0,1)
"	  call Decho("Pass".pass.": extend field: endfield<".strpart(txt,bgnfield,endfield-bgnfield)."> alignop<".alignop."> alignstyle<".alignstyle.">")
	 endwhile
	 let seplen= sepfield - endfield
"	 call Decho("Pass".pass.": seplen=[sepfield=".sepfield."] - [endfield=".endfield."]=".seplen)

	 if endfield != -1
	  if pass == 1
	   " ---------------------------------------------------------------------
	   " Pass 1: Update FieldSize to max
"	   call Decho("Pass".pass.": before lead/trail remove: field<".strpart(txt,bgnfield,endfield-bgnfield).">")
	   let field      = substitute(strpart(txt,bgnfield,endfield-bgnfield),'^\s*\(.\{-}\)\s*$','\1','')
       if s:AlignLeadKeep == 'W'
	    let field = bgntxt.field
	    let bgntxt= ""
	   endif
	   if exists("g:Align_xstrlen") && g:Align_xstrlen
	    let fieldlen   = s:Strlen(field)
	   else
	    let fieldlen   = strlen(field)
	   endif
	   let sFieldSize = "FieldSize_".ifield
	   if !exists(sFieldSize)
	    let FieldSize_{ifield}= fieldlen
"	    call Decho("Pass".pass.":  set FieldSize_{".ifield."}=".FieldSize_{ifield}." <".field.">")
	   elseif fieldlen > FieldSize_{ifield}
	    let FieldSize_{ifield}= fieldlen
"	    call Decho("Pass".pass.": oset FieldSize_{".ifield."}=".FieldSize_{ifield}." <".field.">")
	   endif
	   let sSepSize= "SepSize_".ifield
	   if !exists(sSepSize)
		let SepSize_{ifield}= seplen
"	    call Decho(" set SepSize_{".ifield."}=".SepSize_{ifield}." <".field.">")
	   elseif seplen > SepSize_{ifield}
		let SepSize_{ifield}= seplen
"	    call Decho("Pass".pass.": oset SepSize_{".ifield."}=".SepSize_{ifield}." <".field.">")
	   endif

	  else
	   " ---------------------------------------------------------------------
	   " Pass 2: Perform Alignment
	   let prepad       = strpart(alignprepad,0,1)
	   let postpad      = strpart(alignpostpad,0,1)
	   let alignprepad  = strpart(alignprepad,1).strpart(alignprepad,0,1)
	   let alignpostpad = strpart(alignpostpad,1).strpart(alignpostpad,0,1)
	   let field        = substitute(strpart(txt,bgnfield,endfield-bgnfield),'^\s*\(.\{-}\)\s*$','\1','')
       if s:AlignLeadKeep == 'W'
	    let field = bgntxt.field
	    let bgntxt= ""
	   endif
	   if doend == 2
		let prepad = 0
		let postpad= 0
	   endif
	   if exists("g:Align_xstrlen") && g:Align_xstrlen
	    let fieldlen   = s:Strlen(field)
	   else
	    let fieldlen   = strlen(field)
	   endif
	   let sep        = s:MakeSpace(prepad).strpart(txt,endfield,sepfield-endfield).s:MakeSpace(postpad)
	   if seplen < SepSize_{ifield}
		if alignsepop == "<"
		 " left-justify separators
		 let sep       = sep.s:MakeSpace(SepSize_{ifield}-seplen)
		elseif alignsepop == ">"
		 " right-justify separators
		 let sep       = s:MakeSpace(SepSize_{ifield}-seplen).sep
		else
		 " center-justify separators
		 let sepleft   = (SepSize_{ifield} - seplen)/2
		 let sepright  = SepSize_{ifield} - seplen - sepleft
		 let sep       = s:MakeSpace(sepleft).sep.s:MakeSpace(sepright)
		endif
	   endif
	   let spaces     = FieldSize_{ifield} - fieldlen
"	   call Decho("Pass".pass.": Field #".ifield."<".field."> spaces=".spaces." be[".bgnfield.",".endfield."] pad=".prepad.','.postpad." FS_".ifield."<".FieldSize_{ifield}."> sep<".sep."> ragged=".ragged." doend=".doend." alignop<".alignop.">")

	    " Perform alignment according to alignment style justification
	   if spaces > 0
	    if     alignop == 'c'
		 " center the field
	     let spaceleft = spaces/2
	     let spaceright= FieldSize_{ifield} - spaceleft - fieldlen
	     let newtxt    = newtxt.s:MakeSpace(spaceleft).field.s:MakeSpace(spaceright).sep
	    elseif alignop == 'r'
		 " right justify the field
	     let newtxt= newtxt.s:MakeSpace(spaces).field.sep
	    elseif ragged && doend == 2
		 " left justify rightmost field (no trailing blanks needed)
	     let newtxt= newtxt.field
		else
		 " left justfiy the field
	     let newtxt= newtxt.field.s:MakeSpace(spaces).sep
	    endif
	   elseif ragged && doend == 2
		" field at maximum field size and no trailing blanks needed
	    let newtxt= newtxt.field
	   else
		" field is at maximum field size already
	    let newtxt= newtxt.field.sep
	   endif
"	   call Decho("Pass".pass.": newtxt<".newtxt.">")
	  endif	" pass 1/2

	  " bgnfield indexes to end of separator at right of current field
	  " Update field counter
	  let bgnfield= sepfield
      let ifield  = ifield + 1
	  if doend == 2
	   let doend= 0
	  endif
	   " handle end-of-text as end-of-field
	 elseif doend == 1
	  let seppat  = '$'
	  let doend   = 2
	 else
	  let doend   = 0
	 endif		" endfield != -1
    endwhile	" doend loop (as well as regularly separated fields)

	if pass == 2
	 " Write altered line to buffer
"     call Decho("Pass".pass.": bgntxt<".bgntxt."> line=".line)
"     call Decho("Pass".pass.": newtxt<".newtxt.">")
"     call Decho("Pass".pass.": endtxt<".endtxt.">")
	 call setline(line,bgntxt.newtxt.endtxt)
	endif

    let line = line + 1
   endwhile	" line loop

   let pass= pass + 1
  endwhile	" pass loop
"  call Decho("end of two pass loop")

  " Restore user options
  let &et    = etkeep
  let &paste = pastekeep

  if exists("s:DoAlignPop")
   " AlignCtrl Map support
   call Align#AlignPop()
   unlet s:DoAlignPop
  endif

  " restore current search pattern
  let @/      = keep_search
  let &ic     = keep_ic
  let &report = keep_report

"  call Dret("Align#Align")
  return
endfun

" ---------------------------------------------------------------------
" AlignPush: this command/function pushes an alignment control string onto a stack {{{1
fun! Align#AlignPush()
"  call Dfunc("AlignPush()")

  " initialize the stack
  if !exists("s:AlignCtrlStackQty")
   let s:AlignCtrlStackQty= 1
  else
   let s:AlignCtrlStackQty= s:AlignCtrlStackQty + 1
  endif

  " construct an AlignCtrlStack entry
  if !exists("s:AlignSep")
   let s:AlignSep= ''
  endif
  let s:AlignCtrlStack_{s:AlignCtrlStackQty}= s:AlignCtrl.'p'.s:AlignPrePad.'P'.s:AlignPostPad.s:AlignLeadKeep.s:AlignStyle.s:AlignSep
"  call Decho("AlignPush: AlignCtrlStack_".s:AlignCtrlStackQty."<".s:AlignCtrlStack_{s:AlignCtrlStackQty}.">")

  " push [GV] patterns onto their own stack
  if exists("s:AlignGPat")
   let s:AlignGPat_{s:AlignCtrlStackQty}= s:AlignGPat
  else
   let s:AlignGPat_{s:AlignCtrlStackQty}=  ""
  endif
  if exists("s:AlignVPat")
   let s:AlignVPat_{s:AlignCtrlStackQty}= s:AlignVPat
  else
   let s:AlignVPat_{s:AlignCtrlStackQty}=  ""
  endif

"  call Dret("AlignPush")
endfun

" ---------------------------------------------------------------------
" AlignPop: this command/function pops an alignment pattern from a stack {{1
"           and into the AlignCtrl variables.
fun! Align#AlignPop()
"  call Dfunc("Align#AlignPop()")

  " sanity checks
  if !exists("s:AlignCtrlStackQty")
   echoerr "AlignPush needs to be used prior to AlignPop"
"   call Dret("Align#AlignPop <> : AlignPush needs to have been called first")
   return ""
  endif
  if s:AlignCtrlStackQty <= 0
   unlet s:AlignCtrlStackQty
   echoerr "AlignPush needs to be used prior to AlignPop"
"   call Dret("Align#AlignPop <> : AlignPop needs to have been called first")
   return ""
  endif

  " pop top of AlignCtrlStack and pass value to AlignCtrl
  let retval=s:AlignCtrlStack_{s:AlignCtrlStackQty}
  unlet s:AlignCtrlStack_{s:AlignCtrlStackQty}
  call Align#AlignCtrl(retval)

  " pop G pattern stack
  if s:AlignGPat_{s:AlignCtrlStackQty} != ""
   call Align#AlignCtrl('g',s:AlignGPat_{s:AlignCtrlStackQty})
  else
   call Align#AlignCtrl('g')
  endif
  unlet s:AlignGPat_{s:AlignCtrlStackQty}

  " pop V pattern stack
  if s:AlignVPat_{s:AlignCtrlStackQty} != ""
   call Align#AlignCtrl('v',s:AlignVPat_{s:AlignCtrlStackQty})
  else
   call Align#AlignCtrl('v')
  endif

  unlet s:AlignVPat_{s:AlignCtrlStackQty}
  let s:AlignCtrlStackQty= s:AlignCtrlStackQty - 1

"  call Dret("Align#AlignPop <".retval."> : AlignCtrlStackQty=".s:AlignCtrlStackQty)
  return retval
endfun

" ---------------------------------------------------------------------
" AlignReplaceQuotedSpaces: {{{1
fun! Align#AlignReplaceQuotedSpaces() 
"  call Dfunc("AlignReplaceQuotedSpaces()")

  let l:line          = getline(line("."))
  if exists("g:Align_xstrlen") && g:Align_xstrlen
   let l:linelen      = s:Strlen(l:line)
  else
   let l:linelen      = strlen(l:line)
  endif
  let l:startingPos   = 0
  let l:startQuotePos = 0
  let l:endQuotePos   = 0
  let l:spacePos      = 0
  let l:quoteRe       = '\\\@<!"'

"  "call Decho("in replace spaces.  line=" . line('.'))
  while (1)
    let l:startQuotePos = match(l:line, l:quoteRe, l:startingPos)
    if (l:startQuotePos < 0) 
"      "call Decho("No more quotes to the end of line")
      break
    endif
    let l:endQuotePos = match(l:line, l:quoteRe, l:startQuotePos + 1)
    if (l:endQuotePos < 0)
"      "call Decho("Mismatched quotes")
      break
    endif
    let l:spaceReplaceRe = '^.\{' . (l:startQuotePos + 1) . '}.\{-}\zs\s\ze.*.\{' . (linelen - l:endQuotePos) . '}$'
"    "call Decho('spaceReplaceRe="' . l:spaceReplaceRe . '"')
    let l:newStr = substitute(l:line, l:spaceReplaceRe, '%', '')
    while (l:newStr != l:line)
"      "call Decho('newstr="' . l:newStr . '"')
      let l:line = l:newStr
      let l:newStr = substitute(l:line, l:spaceReplaceRe, '%', '')
    endwhile
    let l:startingPos = l:endQuotePos + 1
  endwhile
  call setline(line('.'), l:line)

"  call Dret("AlignReplaceQuotedSpaces")
endfun

" ---------------------------------------------------------------------
" s:QArgSplitter: to avoid \ processing by <f-args>, <q-args> is needed. {{{1
" However, <q-args> doesn't split at all, so this function returns a list
" of arguments which has been:
"   * split at whitespace
"   * unless inside "..."s.  One may escape characters with a backslash inside double quotes.
" along with a leading length-of-list.
"
"   Examples:   %Align "\""   will align on "s
"               %Align " "    will align on spaces
"
" The resulting list:  qarglist[0] corresponds to a:0
"                      qarglist[i] corresponds to a:{i}
fun! s:QArgSplitter(qarg)
"  call Dfunc("s:QArgSplitter(qarg<".a:qarg.">)")

  if a:qarg =~ '".*"'
   " handle "..." args, which may include whitespace
   let qarglist = []
   let args     = a:qarg
"   call Decho("handle quoted arguments: args<".args.">")
   while args != ""
	let iarg   = 0
	let arglen = strlen(args)
"	call Decho("args[".iarg."]<".args[iarg]."> arglen=".arglen)
	" find index to first not-escaped '"'
	while args[iarg] != '"' && iarg < arglen
	 if args[iarg] == '\'
	  let args= strpart(args,1)
	 endif
	 let iarg= iarg + 1
	endwhile
"	call Decho("args<".args."> iarg=".iarg." arglen=".arglen)

	if iarg > 0
	 " handle left of quote or remaining section
"	 call Decho("handle left of quote or remaining section")
	 if args[iarg] == '"'
	  let qarglist= qarglist + split(strpart(args,0,iarg-1))
	 else
	  let qarglist= qarglist + split(strpart(args,0,iarg))
	 endif
	 let args    = strpart(args,iarg)
	 let arglen  = strlen(args)

	elseif iarg < arglen && args[0] == '"'
	 " handle "quoted" section
"	 call Decho("handle quoted section")
	 let iarg= 1
	 while args[iarg] != '"' && iarg < arglen
	  if args[iarg] == '\'
	   let args= strpart(args,1)
	  endif
	  let iarg= iarg + 1
	 endwhile
"	 call Decho("args<".args."> iarg=".iarg." arglen=".arglen)
	 if args[iarg] == '"'
	  call add(qarglist,strpart(args,1,iarg-1))
	  let args= strpart(args,iarg+1)
	 else
	  let qarglist = qarglist + split(args)
	  let args     = ""
	 endif
	endif
"	call Decho("qarglist".string(qarglist)." iarg=".iarg." args<".args.">")
   endwhile

  else
   " split at all whitespace
   let qarglist= split(a:qarg)
  endif

  let qarglistlen= len(qarglist)
  let qarglist   = insert(qarglist,qarglistlen)
"  call Dret("s:QArgSplitter ".string(qarglist))
  return qarglist
endfun

" ---------------------------------------------------------------------
" s:Strlen: this function returns the length of a string, even if its {{{1
"           using two-byte etc characters.  Depends on virtcol().
"           Currently, its only used if g:Align_xstrlen is set to a
"           nonzero value.  Solution from Nicolai Weibull, vim docs
"           (:help strlen()), Tony Mechelynck, and my own invention.
fun! s:Strlen(x)
"  call Dfunc("s:Strlen(x<".a:x.">")
  if g:Align_xstrlen == 1
   " number of codepoints (Latin a + combining circumflex is two codepoints)
   " (comment from TM, solution from NW)
   let ret= strlen(substitute(a:x,'.','c','g'))

  elseif g:Align_xstrlen == 2
   " number of spacing codepoints (Latin a + combining circumflex is one spacing 
   " codepoint; a hard tab is one; wide and narrow CJK are one each; etc.)
   " (comment from TM, solution from TM)
   let ret=strlen(substitute(a:x, '.\Z', 'x', 'g')) 

  elseif g:Align_xstrlen == 3
   " virtual length (counting, for instance, tabs as anything between 1 and 
   " 'tabstop', wide CJK as 2 rather than 1, Arabic alif as zero when immediately 
   " preceded by lam, one otherwise, etc.)
   " (comment from TM, solution from me)
   let modkeep= &mod
   exe "norm! o\<esc>"
   call setline(line("."),a:x)
   let ret= virtcol("$") - 1
   d
   let &mod= modkeep

  else
   " at least give a decent default
   ret= strlen(a:x)
  endif
"  call Dret("s:Strlen ".ret)
  return ret
endfun

" ---------------------------------------------------------------------
" Set up default values: {{{1
"call Decho("-- Begin AlignCtrl Initialization --")
call Align#AlignCtrl("default")
"call Decho("-- End AlignCtrl Initialization --")

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
