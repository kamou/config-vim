
if !exists('g:bzrstatus_bzr')
  let g:bzrstatus_bzr = 'bzr'
end

command! -nargs=? -complete=file BzrStatus call bzrstatus#start(<f-args>)

