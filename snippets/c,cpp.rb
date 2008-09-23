#! /usr/bin/env ruby

expand "keyword\t" do

  defsnippet 'for ', :c, :cpp, %q[
for (<+init+>; <+cond+>; <+step+>)
{
<+code+>
}
  ]

  defsnippet 'while ', :c, :cpp, %q[
while (<+cond+>)
{
<+code+>
}
  ]

  defsnippet 'switch ', :c, :cpp, %q[
switch (<+value+>)
{
case <+value+>:
<+code+>^^^
break;

default:
<+code+>^^^
break;
}
  ]

  defsnippet 'case ', :c, :cpp, %q[
case <+value+>:
<+code+>^^^
break;
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

