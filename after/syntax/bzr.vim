
" We only want spelling on the commit message part.
if has("spell")
  syn spell toplevel
endif
syn match bzrFirstLine "\%^[^#].*"  nextgroup=bzrRegion skipnl
syn match bzrSummary   "^.\{0,50\}" contained containedin=bzrFirstLine nextgroup=bzrOverflow contains=@Spell
syn match bzrOverflow  ".*" contained contains=@Spell

