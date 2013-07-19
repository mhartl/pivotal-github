require 'pivotal-github/command'
require 'pivotal-github/config_files'

class ProjectOpen < Command
  include ConfigFiles

  def project_url
    "https://www.pivotaltracker.com/projects/#{project_id}"
  end

  def cmd
    "open #{project_url}"
  end

  def run!
    system cmd
  end
end