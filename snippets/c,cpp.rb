#! /usr/bin/env ruby

require 'find'

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

  skel_dir = VIM::evaluate('g:yasnippets_skeletons')

  begin

    cwd = Dir.pwd

    Dir.chdir(skel_dir)

    Find.find('general', 'c') { |skel|

      next if File.directory?(skel)
      next unless File.readable?(skel)

      #VIM::message(skel)

      defsnippet "<%=#{skel}>", :c, :cpp, File.read(skel)
    }

  ensure

    Dir.chdir(cwd)

  end if skel_dir

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

