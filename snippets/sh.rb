#! /usr/bin/env ruby

expand "keyword\t" do

  defsnippet 'while ', :sh, %q[
while <+test+>
do
<+code+>
done
  ]

  defsnippet 'while[ ', :sh, %q[
while [ <+test+> ]
do
<+code+>
done
  ]

  defsnippet 'if ', :sh, %q[
if <+test+>
then
<+code+>
fi
  ]

  defsnippet 'if[ ', :sh, %q[
if [ <+test+> ]
then
<+code+>
fi
  ]

  defsnippet 'for ', :sh, %q[
for <+var+> in <+values+>
do
<+code+>
done
  ]

  defsnippet 'case ', :sh, %q[
case <+value+> in
<+values+>
esac
  ]

end

