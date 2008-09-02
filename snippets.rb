#! /usr/bin/env ruby

expand 'keyword ' do

  defsnippet 'main', :c, :cpp, %q[
int main(int argc, char *argv[])
{
<++>^^^
^^^
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

end

