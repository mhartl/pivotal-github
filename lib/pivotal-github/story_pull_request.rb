require 'pivotal-github/command'

class StoryPullRequest < Command

  def parser
    OptionParser.new do |opts|
      opts.banner = "Usage: git story-pull-request [options]"
      opts.on("-f", "--force", 
              "run without marking story finished") do |f|
        self.options.force = f
      end
      opts.on_tail("-h", "--help", "this usage guide") do
        puts opts.to_s; exit 0
      end
    end
  end

  # Returns a command appropriate for executing at the command line
  # I.e., 'open https://www.pivotaltracker.com/story/show/6283185'
  def cmd
    "open #{uri}"
  end

  def uri
    "#{origin_uri}/pull/new/#{story_branch}"
  end

  def run!
    check_finishes unless force?
    system cmd
  end

  private

    # Returns the remote URI for the repository
    # E.g., https://github.com/mhartl/pivotal-github
    def origin_uri
      `git config --get remote.origin.url`.strip.chomp('.git')
    end

    # Checks to see if the most recent commit finishes the story
    # We look for 'Finishes' or 'Delivers' and issue a warning if neither is
    # in the most recent commit. (Also supports 'Finished' and 'Delivered'.)
    def check_finishes
      unless `git log -1` =~ /Finishe(s|d)|Deliver(s|ed)/
        warning =  "Warning: Unfinished story\n"
        warning += "Run `git commit --amend` to add 'Finishes' or 'Delivers' "
        warning += "to the commit message\n"
        warning += "Use --force to override"
        $stderr.puts warning
        exit 1
      end
    end

    def force?
      options.force
    end
end