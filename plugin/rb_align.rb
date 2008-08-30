#! /usr/bin/env ruby

Part = Struct.new(:str, :delim)

def size(line, c)
  c + 1 < line.size ? line[c].str.size : 0
end

def align(buffer, left, pre_match, surround_pre, delim_match, surround_post, post_match, start_line, end_line)

  align_fn = left ? :ljust : :rjust

  c = 0

  lines = (start_line..end_line).collect { |n|

    line = buffer[n]

    parts = []

    prev = ['', 0]

    rx = /(#{pre_match})(#{delim_match})(#{post_match})/

    line.scan(rx) { |pre, delim, post|

      pre.strip!
      post.strip!

      parts << Part.new(prev[0] + line[prev[1]..($~.begin(0)-1)] + pre, delim)

      prev = [post, $~.end(3)]
    }

    parts << prev[0] + line[prev[1]..-1]

    c = parts.size if parts.size > c

    parts
  }

  0.upto(c - 2) { |c|

    m = lines.max { |l1, l2| size(l1, c) <=> size(l2, c) }

    m = m[c].str.size

    lines.each { |line|

      if c + 1 < line.size
        str = line[c].str.send(align_fn, m)
        str << surround_pre + line[c].delim + surround_post
      else
        str = line[c]
      end

      line[c] = str
    }

    lines.each_with_index { |line, n|

      buffer[start_line + n] = line.join
    }
  }

end

if __FILE__ == $0

  require 'pp'

  lines = STDIN.readlines

  align(lines, true, '\s+|[^=<>+-]', ' ', '=', ' ', '\s*', 0, lines.size - 1)

  puts lines

end
