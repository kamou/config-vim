#! /usr/bin/env ruby

expand 'keyword ' do

  defsnippet 'main', :c, :cpp, %q[
int main(int argc, char *argv[])
{
<++>^^^
return 0;
}
  ]

  defsnippet 'for', :c, :cpp, %q[
for (<+init+>; <+cond+>; <+step+>)
{
<++>
}
  ]

  defsnippet 'while', :c, :cpp, %q[
while (<+cond+>)
{
<++>
}
  ]

  defsnippet 'while', :c, :cpp, %q[
while (<+cond+>)
{
<++>
}
  ]

  defsnippet 'switch', :c, :cpp, %q[
switch (<+value+>)
{
case <+value+>:
<++>^^^
break;

default:
<++>^^^
break;
}
  ]

  defsnippet 'case', :c, :cpp, %q[
case <+value+>:
<++>^^^
break;
  ]



end

