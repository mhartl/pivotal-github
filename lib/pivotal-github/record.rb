require 'optparse'
require 'ostruct'

class Record < Command

  def parse
    options = OpenStruct.new
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: git record [options]"
      opts.on("-m", "--message MESSAGE",
              "add a commit message (with ticket #)") do |m| 
        options.message = m
      end
      opts.on("-a", "--all", "commit all changed files") do |a|
        options.all = a
      end
      opts.on("-f", "--finish", "mark story as finished") do |f|
        options.finish = f
      end
      opts.on_tail("-h", "--help", "this usage guide") do
        puts opts.to_s; exit 0
      end
    end
    self.known_options   =  Options::known_options(parser, args)
    self.unknown_options = Options::unknown_options(parser, args)
    parser.parse(known_options)
    options
  end

  def message
    label = finish? ? "[Finishes ##{story_id}]" : "[##{story_id}]"
    "#{label} #{options.message}"
  end

  # Returns a command appropriate for executing at the command line
  def cmd
    c = ['git commit']
    c << '-a' if all?
    c << %(-m "#{message}") if message?
    c << argument_string(unknown_options) unless unknown_options.empty?
    c.join(' ')
  end

  private

  def finish?
    options.finish
  end

  def message?
    !options.message.nil?
  end

  def all?
    options.all
  end

    # Returns an argument string based on given arguments
    # The main trick is to add in quotes for option
    # arguments when necessary.
    # For example, ['-a', '-m', 'foo bar'] becomes
    # '-a -m "foo bar"'
    def argument_string(args)
      args.inject([]) do |opts, opt|
        opts << (opt =~ /^-/ ? opt : opt.inspect)
      end.join(' ')      
    end
end