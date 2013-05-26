require 'optparse'
require 'ostruct'
require 'pivotal-github/options'

class Command
  attr_accessor :args, :cmd, :options, :known_options, :unknown_options

  def initialize(args = [])
    self.args = args
    self.options = OpenStruct.new
    parse
  end

  def parse
    self.known_options   = Options::known_options(parser, args)
    self.unknown_options = Options::unknown_options(parser, args)
    parser.parse(known_options)
  end

  def parser
    OptionParser.new
  end

  def story_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end

  # Returns the story id (or ids).
  # We extract the story id(s) from the branch name, so that, e.g.,
  # the branch `add-markdown-support-6283185` gives story_id '6283185'.
  # New as of version 0.7, we support multiple story ids in a single 
  # branch name, so that `add-markdown-support-6283185-3141592` can be used
  # to update story 6283185 and story 3141592 simultaneously.
  def story_ids
    story_branch.scan(/\d+/)
  end

  # Returns the single story id for the common case of one id.
  def story_id
    story_ids.first
  end

  # Runs a command.
  # If the argument array contains '--debug', returns the command that would
  # have been run.
  def self.run!(command_class, args)
    debug = args.delete('--debug')
    command = command_class.new(args)
    if debug
      puts command.cmd 
      return 1
    else
      command.run!
      return 0
    end
  end    

  private

    # Returns an argument string based on given arguments.
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