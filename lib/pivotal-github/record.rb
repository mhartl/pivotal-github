require 'optparse'
require 'ostruct'
require 'pivotal-github/options'
require 'pivotal-github/command'

class Record < Command

  def parse
    options = OpenStruct.new
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: git record [options]"
      opts.on("-m", "--message MESSAGE",
              "add a commit message (including story #)") do |m|
        options.message = m
      end
      opts.on("-f", "--finish", "mark story as finished") do |f|
        options.finish = f
      end
      opts.on("-d", "--deliver", "mark story as delivered") do |d|
        options.deliver = d
      end
      opts.on("-a", "--all", "commit all changed files") do |a|
        options.all = a
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
    if story_id.nil?
      # Arranges to fall through to regular 'git commit'
      options.message
    else
      if finish?
        label = "Finishes ##{story_id}"
      elsif deliver?
        label = "Delivers ##{story_id}"
      else
        label = "##{story_id}"
      end
      "[#{label}] #{options.message}".strip
    end
  end

  # Returns a command appropriate for executing at the command line
  # We take care to insert the story number and, if necessary, an indication
  # that the commit finishes the story.
  def cmd
    c = ['git commit']
    c << '-a' if all?
    c << %(-m "#{message}") if message?
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
      !options.message.nil? || finish? || deliver?
    end

    def all?
      options.all
    end
end