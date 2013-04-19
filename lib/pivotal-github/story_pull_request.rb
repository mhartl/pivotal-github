require 'pivotal-github/command'
require 'pivotal-github/finished_command'

class StoryPullRequest < FinishedCommand

  def parser
    OptionParser.new do |opts|
      opts.banner = "Usage: git story-pull-request [options]"
      opts.on("-f", "--force", "override unfinished story warning") do |opt|
        self.options.force = opt
      end
      opts.on("-s", "--skip", "skip `git story-push`") do |opt|
        self.options.skip = opt
      end
      opts.on_tail("-h", "--help", "this usage guide") do
        puts opts.to_s; exit 0
      end
    end
  end

  # Returns a command appropriate for executing at the command line
  # I.e., 'open https://www.pivotaltracker.com/story/show/6283185'
  def cmd
    if skip?
      "open #{uri}"
    else
      "git story-push && open #{uri}"
    end
  end

  def uri
    "#{origin_uri}/pull/new/#{story_branch}"
  end

  private

    # Returns the raw remote location for the repository.
    # E.g., http://github.com/mhartl/pivotal-github or
    # git@github.com:mhartl/pivotal-github
    def remote_location
      `git config --get remote.origin.url`.strip.chomp('.git')
    end

    # Returns the remote URI for the repository.
    # Both https://... and git@... remote formats are supported.
    def origin_uri
      remote_location.sub(/^git@(.+?):(.+)$/, 'https://\1/\2')
    end

    def skip?
      options.skip
    end
end