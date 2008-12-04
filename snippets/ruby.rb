#! /usr/bin/env ruby

ITERATORS = %w{ each collect collect! }

def defiterator(name, brace = false)

  if brace

    code = '{ |<+params+>| <+code+> }'

  else

    code = %q[do |<+params+>|

<+code+>

end]

  end

  defsnippet ".#{name}#{brace ? '{' : ' '}", :ruby, ".#{name} #{code}"

end

expand "keyword\t" do

  ITERATORS.each { |i| defiterator(i) }

end

expand "keyword" do

  ITERATORS.each { |i| defiterator(i, true) }

end
