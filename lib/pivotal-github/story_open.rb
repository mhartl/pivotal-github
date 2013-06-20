require 'pivotal-github/command'
require 'pivotal-github/story'

class StoryOpen < Command
  include Story

  # Returns a command appropriate for executing at the command line
  # I.e., 'open https://www.pivotaltracker.com/story/show/62831853'
  def cmd
    story_ids.map { |id| "open #{story_url(id)}" }.join(' ; ')
  end

  def run!
    system cmd
  end
end