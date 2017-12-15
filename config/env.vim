
" Not VI compatible.
set nocompatible

" Shorten some messages.
set shortmess+=aI

" No wrapping, but use ^ and $ for incomplete lines.
set nowrap
set lcs=precedes:^,extends:$

" Show line numbers.
set number
set relativenumber
set numberwidth=5

" Try to always keep 4 lines of context around cursor.
set scrolloff=4

" To keep hidden buffers
" (so we can change buffer without
" the need to write changes...).
set hidden

" No search highlight, incremental search.
set nohlsearch
set incsearch

" Do not redraw while running macros (much faster).
set lazyredraw

" Disable tabline for better ctrlspace use
set showtabline=0

" Increase command line history.
set history=200

" mark lines exceeding 80 characters.
hi ColorColumn ctermbg=red ctermfg=red
call matchadd('ColorColumn', '\%81v', 100)

" set splitting behaviour
set splitbelow
set splitright

set foldcolumn=2
set foldlevelstart=99

" Save info file in the user VIM directory.
let &viminfo = "!,h,'20,\"50,n".$USERVIM.'/info'

" Activate use of filetype, indent, and plugin.
filetype on
filetype indent on
filetype plugin on

set tabstop=4
set shiftwidth=4
set expandtab

" Allow backspacing over everything in insert mode.
set backspace=2

" Syntax highlighting.
syntax enable

" More info during some commands (like visual selection).
set showcmd

" Fine-tune how VIM formats comments and long lines.
set formatoptions+=croql

" Show statusline even if only one window is visible.
set laststatus=2

" Need -w to correctly parse compilation errors when switching directories.
" Multiple jobs will confuse VIM, so disable those too.
set makeprg=make\ -w\ -j1

let mapleader=" "

" Put swap files in $USERVIM/swap or ~/tmp
" (fallback to current dir if not possible).
let swap = $USERVIM.'/swap'
if !isdirectory(swap)
  call mkdir(swap)
endif
let &directory = swap.'//,~/tmp//,.'

" avoid displaying error messages when /etc/vimrc already have laoded the
" cscope DB
set nocscopeverbose

set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-
set cspc=3

" Uses cstag (and so cscope if available...).
set cst
" Search the tags database before the cscope database...
set csto=1

" Terminal only settings. {{{

if !has('gui_running')

  " Load specific term keys setting.
  " Needed for some mappings to work properly.
  let keys = $USERVIM.'/keys/'.$TERM
  if filereadable(keys)
    execute 'source ' . keys
    if exists('g:term_keys')
      let s:term_keys =
            \ {
            \ 'C-BS'       : 'cin',
            \ 'C-Del'      : 'cin',
            \ 'C-End'      : 'ci ',
            \ 'C-Home'     : 'ci ',
            \ 'C-Left'     : 'ci ',
            \ 'C-PageDown' : 'ci ',
            \ 'C-PageUp'   : 'ci ',
            \ 'C-Right'    : 'ci ',
            \ 'F1'         : 'n',
            \ 'F2'         : 'n',
            \ 'F3'         : 'n',
            \ 'F4'         : 'n',
            \ 'F5'         : 'n',
            \ 'F6'         : 'n',
            \ 'F7'         : 'n',
            \ 'F8'         : 'n',
            \ 'F9'         : 'n',
            \ 'F10'        : 'n',
            \ 'F11'        : 'n',
            \ 'F12'        : 'n',
            \ 'M-0'        : 'n',
            \ 'M-1'        : 'n',
            \ 'M-2'        : 'n',
            \ 'M-3'        : 'n',
            \ 'M-4'        : 'n',
            \ 'M-5'        : 'n',
            \ 'M-6'        : 'n',
            \ 'M-7'        : 'n',
            \ 'M-8'        : 'n',
            \ 'M-9'        : 'n',
            \ 'M-Down'     : 'n',
            \ 'M-Left'     : 'n',
            \ 'M-Right'    : 'n',
            \ 'M-Up'       : 'n',
            \ 'S-Down'     : 'i ',
            \ 'S-Left'     : 'i ',
            \ 'S-Right'    : 'i ',
            \ 'S-Up'       : 'i ',
            \ 'M-BS'       : 'cin',
            \ }
      for key_name in keys(s:term_keys)
        if !has_key(g:term_keys, key_name)
          continue
        endif
        let key_code = g:term_keys[key_name]
        let key_modes = s:term_keys[key_name]
        for n in range(strlen(key_modes))
          let mode = key_modes[n]
          let map = mode.'map '.key_code.' <'.key_name.'>'
          exe map
        endfor
      endfor
    endif
  endif

  " Fast escape key.
  set timeout timeoutlen=3000 ttimeoutlen=100

  " No beep, and no visual bell.
  set vb t_vb=

endif

" Cursor cross.
augroup crosscursor
    autocmd!
    autocmd VimEnter    * set cursorline cursorcolumn
    autocmd BufWinEnter * set cursorline cursorcolumn
    autocmd WinEnter    * set cursorline cursorcolumn
    autocmd WinLeave    * set nocursorline nocursorcolumn
augroup END

set guicursor=
set mouse=
