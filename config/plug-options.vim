
" DirDiff options.
let g:DirDiffExcludes = 'CVS,.svn,.bzr,.git,.hg,cscope*.out*,tags,*_debug,*.~[0-9]~,*.~[0-9][0-9]~,*.orig'
let g:DirDiffAddArgs = '--strip-trailing-cr'
let g:DirDiffVerboseSync = 0
let g:DirDiffDynamicDiffText = 1
let g:DirDiffQuitConfirm = 0

" Configure netrw plugin to use wget rather than elinks; this fix the case
" where VIM will ask and fetch missing dictionaries.
let g:netrw_http_cmd = 'wget -O'
" Also disable banner.
let g:netrw_banner = 0
" Do not show dotfiles per default.
let g:netrw_hide = 1
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'

" vim-cpp-enhanced-highlight highlighting configuration
let g:cpp_class_scope_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_concepts_highlight = 1

" Airline options
let g:airline_powerline_fonts = 1
let g:airline#extensions#ctrlspace#enabled = 1
let g:airline_theme='lucius'

if executable("ag")
    let g:CtrlSpaceGlobCommand = 'ag -l --nocolor -g ""'
endif

" syntastic options
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_loc_list_height = 3
let g:syntastic_cpp_check_header = 1
let g:syntastic_cpp_remove_include_errors = 1
let g:syntastic_c_check_header = 1
let g:syntastic_c_remove_include_errors = 0
let g:syntastic_c_no_include_search = 0

" tmux-navigator options
let g:tmux_navigator_no_mappings = 1

" use custom indentwise mappings
let g:indentwise_suppress_keymaps = 1


let g:clang_format#command = "clang-format-3.9"
let g:clang_format#detect_style_file = 1

let g:rainbow_active = 1
" enable Gtags module
let g:gutentags_modules = ['ctags', 'cscope']

" config project root markers
let g:gutentags_project_root = ['.root']
let g:gutentags_cache_dir = expand('~/.cache/tags') 
let g:gutentags_auto_add_cscope = 1
let g:pymode_rope = 1
