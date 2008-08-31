#! /usr/bin/env ruby

Part = Struct.new(:str, :delim)

def str_size(line, c)
  c + 1 < line.size ? line[c].str.size : 0
end

def delim_size(line, c)
  line[c].kind_of?(Part) ? line[c].delim.size : 0
end

def align(buffer, left, pre_match, surround_pre, delim_match, surround_post, post_match, start_line, end_line, range = nil)

  align_fn = left ? :ljust : :rjust

  c = 0

  if delim_match.kind_of?(Array)
    delim_match, delim_group = delim_match
    delim_group += 1
  else
    delim_group = 2
  end

  rx = /(#{pre_match})(#{delim_match})(#{post_match})/

  lines = (start_line..end_line).collect { |n|

    line = buffer[n]

    parts = []

    prev = ['', 0]

    line.scan(rx) {

      pre, delim, post = $~[1], $~[delim_group], $~[delim_group + 1]

      pre.strip!
      post.strip!

      parts << Part.new(prev[0] + line[prev[1]..($~.begin(0)-1)] + pre, delim)

      prev = [post, $~.end(delim_group + 1)]
    }

    parts << prev[0] + line[prev[1]..-1]

    c = parts.size if parts.size > c

    parts
  }

  range ||= 0..(c-2)
  range.end = c - 1 if range.end >= c

  range.each { |c|

    max_str_size = lines.max { |l1, l2| str_size(l1, c) <=> str_size(l2, c) }
    max_str_size = str_size(max_str_size, c)

    max_delim_size = lines.max { |l1, l2| delim_size(l1, c) <=> delim_size(l2, c) }
    max_delim_size =  delim_size(max_delim_size, c)

    lines.each { |line|

      if c + 1 < line.size
        str = line[c].str.send(align_fn, max_str_size)
        str << surround_pre + line[c].delim.send(align_fn, max_delim_size) + surround_post
      else
        str = line[c]
      end

      line[c] = str
    }
  }

  lines.each_with_index { |line, n|

    line.collect! { |l| l.kind_of?(Part) ? l.str : l }
    buffer[start_line + n] = line.join
  }

end

if __FILE__ == $0

  require 'pp'

  lines = STDIN.readlines

  #align(lines, true, '\s+|[^=<>+-]', ' ', '=', ' ', '\s*', 0, lines.size - 1)
  align(lines, true, '(\b(static|const|volatile|enum|struct|union)\b\s+)*\w+\s*', ' ', ['\**', 3], '', '\s*', 0, lines.size - 1, 0..0)

  puts lines

end
