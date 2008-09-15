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

expand 'keyword<' do

  defsnippet '#include', :cpp, %q[
    #include <<+header+>>
  ]

  defsnippet '#inc', :c, :cpp, %q[
    #include <<+header+>>
  ]

end

expand 'keyword"' do

  defsnippet '#include', :c, :cpp, %q[
    #include \"<+header+>\"
  ]

  defsnippet '#inc', :c, :cpp, %q[
    #include \"<+header+>\"
  ]

end

