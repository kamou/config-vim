#!/usr/bin/env ruby

expand "keyword\t" do

  defsnippet 'do ', :lua, %q[
do
<+block+>
end
  ]

  defsnippet 'while ', :lua, %q[
while <+exp+> do
<+block+>
end
  ]

  defsnippet 'repeat ', :lua, %q[
repeat
<+block+>
until <+exp+>
  ]

  defsnippet 'if ', :lua, %q[
if <+exp+> then
<+block+>
end
  ]

  defsnippet 'ifelse ', :lua, %q[
if <+exp+> then
<+block+>
else
<+block+>
end
  ]

  defsnippet 'elseif ', :lua, %q[
elseif <+exp+> then
<+block+>
end
  ]

  defsnippet 'for ', :lua, %q[
for <+namelist+> in <+explist+> do
<+block+>
end
  ]

  defsnippet 'function ', :lua, %q[
function <+name+> (<+parlist+>)
<+body+>
end
  ]

  defsnippet 'function)', :lua, %q[
function <+name+> ()
<+body+>
end
  ]

  defsnippet 'function(', :lua, %q[
function (<+parlist+>)
<+body+>
end
  ]

  defsnippet 'function()', :lua, %q[
function ()
<+body+>
end
  ]

end

