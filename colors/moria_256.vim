if exists("g:moria_style")
    let s:moria_style = g:moria_style
else
    let s:moria_style = &background
endif

if exists("g:moria_monochrome")
    let s:moria_monochrome = g:moria_monochrome
else
    let s:moria_monochrome = 0
endif

if exists("g:moria_fontface")
    let s:moria_fontface = g:moria_fontface
else
    let s:moria_fontface = "plain"
endif

execute "command! -nargs=1 Colo let g:moria_style = \"<args>\" | colo moria"

if s:moria_style == "black" || s:moria_style == "dark"
    set background=dark
elseif s:moria_style == "light" || s:moria_style == "white"
    set background=light
else
    let s:moria_style = &background
endif

hi clear

if exists("syntax_on")
    syntax reset
endif

let colors_name = "moria_256"

if &background == "dark"
    if s:moria_style == "dark"
        hi Normal guibg=#202020 ctermbg=234 guifg=#d0d0d0 ctermfg=252 gui=none

        hi CursorColumn guibg=#404040 ctermbg=238 gui=none
        hi CursorLine guibg=#404040 ctermbg=238 gui=none
    elseif s:moria_style == "black"
        hi Normal guibg=#000000 ctermbg=0 guifg=#d0d0d0 ctermfg=252 gui=none

        hi CursorColumn guibg=#3a3a3a ctermbg=237 gui=none
        hi CursorLine guibg=#3a3a3a ctermbg=237 gui=none
    endif
    if s:moria_monochrome == 1
        hi FoldColumn guibg=bg guifg=#a0a0a0 ctermfg=247 gui=none
        hi LineNr guifg=#a0a0a0 ctermfg=247 gui=none
        hi MoreMsg guibg=bg guifg=#b6b6b6 ctermfg=249 gui=bold
        hi NonText guibg=bg guifg=#a0a0a0 ctermfg=247 gui=bold
        hi Pmenu guibg=#909090 ctermbg=246 guifg=#000000 ctermfg=0 gui=none
        hi PmenuSbar guibg=#707070 ctermbg=242 guifg=fg gui=none
        hi PmenuThumb guibg=#d0d0d0 ctermbg=252 guifg=bg gui=none
        hi SignColumn guibg=bg guifg=#a0a0a0 ctermfg=247 gui=none
        hi StatusLine guibg=#4c4c4c ctermbg=239 guifg=fg gui=bold
        hi StatusLineNC guibg=#404040 ctermbg=238 guifg=fg gui=none
        hi TabLine guibg=#6e6e6e ctermbg=242 guifg=fg gui=underline
        hi TabLineFill guibg=#6e6e6e ctermbg=242 guifg=fg gui=underline
        hi VertSplit guibg=#404040 ctermbg=238 guifg=fg gui=none
        if s:moria_fontface == "mixed"
            hi Folded guibg=#4e4e4e ctermbg=239 guifg=#c0c0c0 ctermfg=250 gui=bold
        else
            hi Folded guibg=#4e4e4e ctermbg=239 guifg=#c0c0c0 ctermfg=250 gui=none
        endif
    else
        hi FoldColumn ctermbg=bg guibg=bg guifg=#9a9fc7 ctermfg=110 gui=none
        hi LineNr guifg=#9a9fc7 ctermfg=110 gui=none
        hi MoreMsg guibg=bg guifg=#a0a6cb ctermfg=146 gui=bold
        hi NonText guibg=bg guifg=#9a9fc7 ctermfg=110 gui=bold
        hi Pmenu guibg=#7179b0 ctermbg=67 guifg=#000000 ctermfg=0 gui=none
        hi PmenuSbar guibg=#50588f ctermbg=60 guifg=fg gui=none
        hi PmenuThumb guibg=#c2c6de ctermbg=252 guifg=bg gui=none
        hi SignColumn ctermbg=bg guibg=bg guifg=#9a9fc7 ctermfg=110 gui=none
        hi StatusLine ctermbg=LightGray ctermfg=235 guibg=#3f4572 gui=bold
        hi StatusLineNC guibg=#2e3252 ctermbg=237 guifg=fg gui=none
        hi TabLine guibg=#50588f ctermbg=60 guifg=fg gui=underline
        hi TabLineFill guibg=#50588f ctermbg=60 guifg=fg gui=underline
        hi VertSplit guibg=#2e3252 ctermbg=237 guifg=fg gui=none
        if s:moria_fontface == "mixed"
            hi Folded guibg=#4e4e4e ctermbg=239 guifg=#c2c6de ctermfg=252 gui=bold
        else
            hi Folded guibg=#4e4e4e ctermbg=239 guifg=#c2c6de ctermfg=252 gui=none
        endif
    endif
    hi Cursor guibg=#ffa500 ctermbg=214 guifg=bg gui=none
    hi DiffAdd guibg=#008b00 ctermbg=28 guifg=fg gui=none
    hi DiffChange guibg=#00008b ctermbg=18 guifg=fg gui=none
    hi DiffDelete guibg=#8b0000 ctermbg=88 guifg=fg gui=none
    hi DiffText guibg=#0000cd ctermbg=20 guifg=fg gui=bold
    hi Directory guibg=bg guifg=#1e90ff ctermfg=33 gui=none
    hi ErrorMsg guibg=#ee2c2c ctermbg=9 guifg=#ffffff ctermfg=15 gui=bold
    hi IncSearch guibg=#e0cd78 ctermbg=186 guifg=#000000 ctermfg=0 gui=none
    hi ModeMsg guibg=bg guifg=fg gui=bold
    hi PmenuSel guibg=#e0e000 ctermbg=184 guifg=#000000 ctermfg=0 gui=none
    hi Question guibg=bg guifg=#e8b87e ctermfg=180 gui=bold
    hi Search guibg=#90e090 ctermbg=114 guifg=#000000 ctermfg=0 gui=none
    hi SpecialKey guibg=bg guifg=#e8b87e ctermfg=180 gui=none
    if has("spell")
        hi SpellBad guisp=#ee2c2c gui=undercurl
        hi SpellCap guisp=#2c2cee gui=undercurl
        hi SpellLocal guisp=#2ceeee gui=undercurl
        hi SpellRare guisp=#ee2cee gui=undercurl
    endif
    hi TabLineSel guibg=bg guifg=fg gui=bold
    hi Title guifg=fg gui=bold
    if version >= 700
        hi Visual guibg=#606060 ctermbg=59 gui=none
    else
        hi Visual guibg=#606060 ctermbg=59 guifg=fg gui=none
    endif
    hi VisualNOS guibg=bg guifg=#a0a0a0 ctermfg=247 gui=bold,underline
    hi WarningMsg guibg=bg guifg=#ee2c2c ctermfg=9 gui=bold
    hi WildMenu guibg=#e0e000 ctermbg=184 guifg=#000000 ctermfg=0 gui=bold

    hi Comment guibg=bg guifg=#d0d0a0 ctermfg=187 gui=none
    hi Constant guibg=bg guifg=#87df71 ctermfg=113 gui=none
    hi Error guibg=bg guifg=#ee2c2c ctermfg=9 gui=none
    hi Identifier guibg=bg guifg=#7ee0ce ctermfg=116 gui=none
    hi Ignore guibg=bg guifg=bg gui=none
    hi lCursor guibg=#00e700 ctermbg=40 guifg=#000000 ctermfg=0 gui=none
    hi MatchParen guibg=#008b8b ctermbg=30 gui=none
    hi PreProc guibg=bg guifg=#d7a0d7 ctermfg=182 gui=none
    hi Special guibg=bg guifg=#e8b87e ctermfg=215 gui=none
    hi Todo guibg=#e0e000 ctermbg=184 guifg=#000000 ctermfg=0 gui=none
    hi Underlined guibg=bg guifg=#00a0ff ctermfg=39 gui=underline

    if s:moria_fontface == "mixed"
        hi Statement guibg=bg guifg=#7ec0ee ctermfg=111 gui=bold
        hi Type guibg=bg guifg=#f09479 ctermfg=210 gui=bold
    else
        hi Statement guibg=bg guifg=#7ec0ee ctermfg=111 gui=none
        hi Type guibg=bg guifg=#f09479 ctermfg=210 gui=none
    endif

    hi htmlBold guibg=bg guifg=fg gui=bold
    hi htmlBoldItalic guibg=bg guifg=fg gui=bold,italic
    hi htmlBoldUnderline guibg=bg guifg=fg gui=bold,underline
    hi htmlBoldUnderlineItalic guibg=bg guifg=fg gui=bold,underline,italic
    hi htmlItalic guibg=bg guifg=fg gui=italic
    hi htmlUnderline guibg=bg guifg=fg gui=underline
    hi htmlUnderlineItalic guibg=bg guifg=fg gui=underline,italic
elseif &background == "light"
    if s:moria_style == "light"
        hi Normal guibg=#f0f0f0 ctermbg=7 guifg=#000000 ctermfg=0 gui=none

        hi CursorColumn guibg=#d8d8d8 ctermbg=188 gui=none
        hi CursorLine guibg=#d8d8d8 ctermbg=188 gui=none
    elseif s:moria_style == "white"
        hi Normal guibg=#ffffff ctermbg=15 guifg=#000000 ctermfg=0 gui=none

        hi CursorColumn guibg=#dfdfdf ctermbg=7 gui=none
        hi CursorLine guibg=#dfdfdf ctermbg=7 gui=none
    endif
    if s:moria_monochrome == 1
        hi FoldColumn guibg=bg guifg=#7a7a7a ctermfg=243 gui=none
        hi Folded guibg=#cfcfcf ctermbg=252 guifg=#404040 ctermfg=238 gui=bold
        hi LineNr guifg=#7a7a7a ctermfg=243 gui=none
        hi MoreMsg guibg=bg guifg=#505050 ctermfg=239 gui=bold
        hi NonText guibg=bg guifg=#7a7a7a ctermfg=243 gui=bold
        hi Pmenu guibg=#9a9a9a ctermbg=247 guifg=#000000 ctermfg=0 gui=none
        hi PmenuSbar guibg=#808080 ctermbg=244 guifg=fg gui=none
        hi PmenuThumb guibg=#c0c0c0 ctermbg=250 guifg=fg gui=none
        hi SignColumn guibg=bg guifg=#7a7a7a ctermfg=243 gui=none
        hi StatusLine guibg=#a0a0a0 ctermbg=247 guifg=fg gui=bold
        hi StatusLineNC guibg=#b0b0b0 ctermbg=145 guifg=fg gui=none
        hi TabLine guibg=#cdcdcd ctermbg=252 guifg=fg gui=underline
        hi TabLineFill guibg=#cdcdcd ctermbg=252 guifg=fg gui=underline
        hi VertSplit guibg=#b0b0b0 ctermbg=145 guifg=fg gui=none
    else
        hi FoldColumn guibg=bg guifg=#444b7b ctermfg=60 gui=none
        hi Folded guibg=#cfcfcf ctermbg=252 guifg=#2e3252 ctermfg=237 gui=bold
        hi LineNr guifg=#444b7b ctermfg=60 gui=none
        hi MoreMsg guibg=bg guifg=#383f67 ctermfg=239 gui=bold
        hi NonText guibg=bg guifg=#444b7b ctermfg=60 gui=bold
        hi Pmenu guibg=#7d85b7 ctermbg=103 guifg=#000000 ctermfg=0 gui=none
        hi PmenuSbar guibg=#5a64a5 ctermbg=61 guifg=fg gui=none
        hi PmenuThumb guibg=#aeb3d2 ctermbg=146 guifg=fg gui=none
        hi SignColumn guibg=bg guifg=#444b7b ctermfg=60 gui=none
        hi StatusLine guibg=#9a9fc7 ctermbg=110 guifg=fg gui=bold
        hi StatusLineNC guibg=#aeb3d2 ctermbg=146 guifg=fg gui=none
        hi TabLine guibg=#bec2dc ctermbg=251 guifg=fg gui=underline
        hi TabLineFill guibg=#bec2dc ctermbg=251 guifg=fg gui=underline
        hi VertSplit guibg=#aeb3d2 ctermbg=146 guifg=fg gui=none
    endif
    hi Cursor guibg=#883400 ctermbg=94 guifg=bg gui=none
    hi DiffAdd guibg=#008b00 ctermbg=28 guifg=#ffffff ctermfg=15 gui=none
    hi DiffChange guibg=#00008b ctermbg=18 guifg=#ffffff ctermfg=15 gui=none
    hi DiffDelete guibg=#8b0000 ctermbg=88 guifg=#ffffff ctermfg=15 gui=none
    hi DiffText guibg=#0000cd ctermbg=20 guifg=#ffffff ctermfg=15 gui=bold
    hi Directory guibg=bg guifg=#0000f0 ctermfg=4 gui=none
    hi ErrorMsg guibg=#ee2c2c ctermbg=9 guifg=#ffffff ctermfg=15 gui=bold
    hi IncSearch guibg=#ffcd78 ctermbg=222 gui=none
    hi ModeMsg guibg=bg guifg=fg gui=bold
    hi PmenuSel guibg=#ffff00 ctermbg=11 guifg=#000000 ctermfg=0 gui=none
    hi Question guibg=bg guifg=#813f11 ctermfg=94 gui=bold
    hi Search guibg=#a0f0a0 ctermbg=157 gui=none
    hi SpecialKey guibg=bg guifg=#912f11 ctermfg=88 gui=none
    if has("spell")
        hi SpellBad guisp=#ee2c2c gui=undercurl
        hi SpellCap guisp=#2c2cee gui=undercurl
        hi SpellLocal guisp=#008b8b gui=undercurl
        hi SpellRare guisp=#ee2cee gui=undercurl
    endif
    hi TabLineSel guibg=bg guifg=fg gui=bold
    hi Title guifg=fg gui=bold
    if version >= 700
        hi Visual guibg=#c4c4c4 ctermbg=251 gui=none
    else
        hi Visual guibg=#c4c4c4 ctermbg=251 guifg=fg gui=none
    endif
    hi VisualNOS guibg=bg guifg=#a0a0a0 ctermfg=247 gui=bold,underline
    hi WarningMsg guibg=bg guifg=#ee2c2c ctermfg=9 gui=bold
    hi WildMenu guibg=#ffff00 ctermbg=11 guifg=fg gui=bold

    hi Comment guibg=bg guifg=#786000 ctermfg=94 gui=none
    hi Constant guibg=bg guifg=#077807 ctermfg=28 gui=none
    hi Error guibg=bg guifg=#ee2c2c ctermfg=9 gui=none
    hi Identifier guibg=bg guifg=#007080 ctermfg=24 gui=none
    hi Ignore guibg=bg guifg=bg gui=none
    hi lCursor guibg=#008000 ctermbg=28 guifg=#ffffff ctermfg=15 gui=none
    hi MatchParen guibg=#00ffff ctermbg=14 gui=none
    hi PreProc guibg=bg guifg=#800090 ctermfg=90 gui=none
    hi Special guibg=bg guifg=#912f11 ctermfg=88 gui=none
    hi Statement guibg=bg guifg=#1f3f81 ctermfg=24 gui=bold
    hi Todo guibg=#ffff00 ctermbg=11 guifg=fg gui=none
    hi Type guibg=bg guifg=#912f11 ctermfg=88 gui=bold
    hi Underlined guibg=bg guifg=#0000cd ctermfg=20 gui=underline

    hi htmlBold guibg=bg guifg=fg gui=bold
    hi htmlBoldItalic guibg=bg guifg=fg gui=bold,italic
    hi htmlBoldUnderline guibg=bg guifg=fg gui=bold,underline
    hi htmlBoldUnderlineItalic guibg=bg guifg=fg gui=bold,underline,italic
    hi htmlItalic guibg=bg guifg=fg gui=italic
    hi htmlUnderline guibg=bg guifg=fg gui=underline
    hi htmlUnderlineItalic guibg=bg guifg=fg gui=underline,italic
endif

hi! default link bbcodeBold htmlBold
hi! default link bbcodeBoldItalic htmlBoldItalic
hi! default link bbcodeBoldItalicUnderline htmlBoldUnderlineItalic
hi! default link bbcodeBoldUnderline htmlBoldUnderline
hi! default link bbcodeItalic htmlItalic
hi! default link bbcodeItalicUnderline htmlUnderlineItalic
hi! default link bbcodeUnderline htmlUnderline
