require 'pivotal-github/command'
require 'pivotal-github/finished_command'
require 'pivotal-github/story'

class StoryPullRequest < FinishedCommand
  include Story

  def parser
    OptionParser.new do |opts|
      opts.banner = "Usage: git story-pull-request [options]"
      opts.on("-b <branch>", "--base-branch <branch>",
              "base branch for delivered ids") do |opt|
        self.options.base_branch = opt
      end
      opts.on("-o", "--override", "override unfinished story warning") do |opt|
        self.options.override = opt
      end
      opts.on_tail("-h", "--help", "this usage guide") do
        puts opts.to_s; exit 0
      end
    end
  end

  # Returns the (Markdown) link for a delivered story id.
  def delivers_url(id)
    "[Delivers ##{id}](#{story_url(id)})"
  end

  def base_branch
    options.base_branch || 'master'
  end

  # Returns a commit message with links to all the delivered stories.
  def commit_message
    ids = delivered_ids(`git log #{base_branch}..HEAD`)
    ids.map { |id| delivers_url(id) }.join("\n")
  end

  # Returns a command appropriate for executing at the command line
  def cmd
    Dir.mkdir '.pull_requests' unless File.directory?('.pull_requests')
    c =  ["touch .pull_requests/`date '+%s'`"]
    c << "git add ."
    c << %(git commit -m "Pull request" -m "#{commit_message}")
    c << "git pull-request"
    c.join("\n")
  end

  private
end