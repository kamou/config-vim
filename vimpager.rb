#! /usr/bin/env ruby

$DEBUG = false

# def exec(*args) end

squeeze_blank_lines = false
quit_if_one_screen = false
man_page = false

ARGV.collect! do |arg|

  case arg
  when '-s'
    squeeze_blank_lines = true
    nil
  when '-F'
    quit_if_one_screen = true
    nil
  when '--man'
    man_page = true
    nil
  when '--'
    break
  when /^-/
    raise "unsupported option #{arg}"
  else
    arg
  end

end

ARGV.compact!

unless STDOUT.isatty

  previous_line_blank = false

  while STDIN.gets

    if squeeze_blank_lines and $_ =~ /^\s*$/
      print $_ unless previous_line_blank
      previous_line_blank = true
    else
      print $_
      previous_line_blank = false
    end

  end

  exit 0

end

VIMPAGER_RC = ENV.fetch('VIMPAGER_RC', File.join(ENV['HOME'], '.vim', 'rc.pager'))

unless File.readable?(VIMPAGER_RC)

  cmd = %w{ less }
  cmd << '-s' if squeeze_blank_lines
  cmd << '-F' if quit_if_one_screen
  cmd.concat(ARGV)

  STDERR.puts cmd if $DEBUG

  exec(*cmd)
  exit 255

end

cmd = %w{ view -u }
cmd << VIMPAGER_RC

if man_page
  cmd << '-c'
  cmd << 'set ft=man'
end

if quit_if_one_screen
  ENV['VLESS_OPT'] = '-F'
end

if ARGV.empty?

  rd, wr = IO.pipe

  unless fork

    rd.close
    STDOUT.reopen(wr)

    child_cmd = %w{ col -x -b }

    STDERR.write "#{child_cmd} | " if $DEBUG

    exec(*child_cmd)
    exit 255

  end

  wr.close
  STDIN.reopen(rd)

  cmd << '-'

else

  cmd.concat(ARGV)

end

STDERR.puts cmd if $DEBUG

exec(*cmd)
exit 255
