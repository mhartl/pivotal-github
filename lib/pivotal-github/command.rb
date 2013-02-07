class Command
  attr_accessor :args, :cmd, :options, :known_options, :unknown_options

  def initialize(args = [])
    self.args = args
    parse
  end

  def parse
    raise "Define in derived class"
  end

  def current_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end

  def story_id
    current_branch.scan(/\d+/).first
  end

  def options
    @options ||= parse
  end

  # Runs a command
  # If the argument array contains '--debug', returns the command that would
  # have been run
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