require 'optparse'
require 'ostruct'
require 'pivotal-github/options'
require 'pivotal-github/command'

class Submit < Command

  # attr_accessor :branch

  def parse
    options = OpenStruct.new
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: git submit [options]"
      opts.on("-p", "--pull-request BRANCH",
              "submit a pull request to a branch other than master") do |b|
        options.branch = b
      end
      opts.on_tail("-h", "--help", "this usage guide") do
        puts opts.to_s; exit 0
      end
    end
    self.known_options   = Options::known_options(parser, args)
    self.unknown_options = Options::unknown_options(parser, args)
    parser.parse(known_options)
    options
  end

  def pull_request_branch
    options.branch || 'master'
  end

  # Returns a command appropriate for executing at the command line
  # We take care to insert the story number and, if necessary, an indication
  # that the commit finishes the story.
  def cmd
    c = ['git push']
    c << 'origin'
    c << current_branch
    c << argument_string(unknown_options) unless unknown_options.empty?
    c.join(' ')
  end

  def run!
    system cmd
  end

  private

    def finish?
      options.finish
    end

    def deliver?
      options.deliver
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