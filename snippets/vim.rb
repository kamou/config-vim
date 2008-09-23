#! /usr/bin/env ruby

expand "keyword\t" do

  defsnippet 'func ', :vim, %q[
function <+name+>

<+code+>

endfunction
  ]

  defsnippet 'func! ', :vim, %q[
function! <+name+>

<+code+>

endfunction
  ]

end

