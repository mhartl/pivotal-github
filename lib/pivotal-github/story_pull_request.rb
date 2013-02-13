require 'pivotal-github/command'

class StoryPullRequest < Command

  # Returns a command appropriate for executing at the command line
  # I.e., 'open https://www.pivotaltracker.com/story/show/6283185'
  def cmd
    "open #{uri}"
  end

  def uri
    "#{origin_uri}/pull/new/#{story_branch}"
  end

  def run!
    system cmd
  end

  private

    # Returns the remote URI for the repository
    # E.g., https://github.com/mhartl/pivotal-github
    def origin_uri
      `git config --get remote.origin.url`.strip.chomp('.git')
    end  
end