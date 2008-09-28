#! /usr/bin/env ruby

require 'find'

def load_skeleton_snippets(directory, *filetypes)

  expand "keyword\t" do

    skel_dir = VIM::evaluate('g:yasnippets_skeletons')

    begin

      cwd = Dir.pwd

      Dir.chdir(skel_dir)

      Find.find(directory) { |skel|

        next if File.directory?(skel)
        next unless File.readable?(skel)

        #VIM::message(skel)

        args = [ "<%=#{skel}>" ]
        args.concat(filetypes)
        args << File.read(skel)

        defsnippet(*args)
      }

    ensure

      Dir.chdir(cwd)

    end if skel_dir

  end

end

load_skeleton_snippets('general', :all)

Dir.glob(File.join(ENV['USERVIM'], 'snippets', '*.rb')) { |entry|

  load(entry)
}
