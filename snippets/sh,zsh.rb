#! /usr/bin/env ruby

expand "keyword\t" do

  defsnippet 'while ', :sh, :zsh, %q[
while <+test+>
do
<+code+>
done
  ]

  defsnippet 'while[', :sh, :zsh, %q[
while [ <+test+> ]
do
<+code+>
done
  ]

  defsnippet 'if ', :sh, :zsh, %q[
if <+test+>
then
<+code+>
fi
  ]

  defsnippet 'if[', :sh, :zsh, %q[
if [ <+test+> ]
then
<+code+>
fi
  ]

  defsnippet 'for ', :sh, :zsh, %q[
for <+var+> in <+values+>
do
<+code+>
done
  ]

  defsnippet 'case ', :sh, :zsh, %q[
case <+value+> in
<+values+>
esac
  ]

end

