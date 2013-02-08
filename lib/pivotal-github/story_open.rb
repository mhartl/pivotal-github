require 'pivotal-github/command'

class StoryOpen < Command

  # Returns a command appropriate for executing at the command line
  # I.e., 'open https://www.pivotaltracker.com/story/show/6283185'
  def cmd
    "open https://www.pivotaltracker.com/story/show/#{story_id}"
  end

  def run!
    system cmd
  end
end