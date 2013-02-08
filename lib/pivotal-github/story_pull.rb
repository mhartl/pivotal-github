require 'pivotal-github/command'

class StoryPull < Command

  def parser
    OptionParser.new do |opts|
      opts.banner = "Usage: git story-pull [options]"
      opts.on("-d", "--development BRANCH",
              "development branch (defaults to master)") do |opt|
        self.options.development = opt
      end
      opts.on_tail("-h", "--help", "this usage guide") do
        puts opts.to_s; exit 0
      end
    end
  end

  # Returns a command appropriate for executing at the command line
  # For example:
  #   git checkout master
  #   git pull
  #   git checkout <story branch>
  def cmd
    lines = ["git checkout #{development_branch}"]
    c = ['git pull']
    c << argument_string(unknown_options) unless unknown_options.empty?
    lines << c.join(' ')
    lines << ["git checkout #{story_branch}"]
    lines.join("\n")
  end

  def run!
    system cmd
  end

  private

    def pull_request_branch
      options.pull_request_branch
    end

    def development_branch
      options.development || 'master'
    end
end