#! /usr/bin/env ruby

Dir.glob(File.join(ENV['USERVIM'], 'snippets', '*.rb')) { |entry|

  load(entry)
}
