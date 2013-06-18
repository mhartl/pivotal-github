require 'pivotal-github/command'
require 'git'
require 'net/http'
require 'uri'

class StoryAccept < Command

  def parser
    OptionParser.new do |opts|
      opts.banner = "Usage: git story-accept"
      opts.on("-o", "--override", "override master branch requirement") do |opt|
        self.options.override = opt
      end
      opts.on("-a", "--all", "process all stories") do |opt|
        self.options.all = opt
      end
      opts.on_tail("-h", "--help", "this usage guide") do
        puts opts.to_s; exit 0
      end
    end
  end

  # Returns the ids to accept.
  # These ids are of the form [Delivers #<story id>] or
  # [Delivers #<story id> #<another story id>].
  def ids_to_accept
    delivered_regex = /\[Deliver(?:s|ed) (.*?)\]/
    Git.open('.').log.inject([]) do |return_ids, commit|
      message = commit.message
      delivered = message.scan(delivered_regex).flatten
      commit_ids = delivered.inject([]) do |ids, element|
        ids.concat(element.scan(/[0-9]{8,}/).flatten)
        ids
      end
      return_ids += commit_ids
      return_ids.uniq
    end
  end

  def api_token
    api_filename = '.api_token'
    if File.exist?(api_filename)
      @api_token ||= File.read(api_filename).strip
    else
      puts "Please create a file called '#{api_filename}'"
      puts "containing your Pivotal Tracker API token."
      exit 1
    end
  end

  def project_id
    project_id_filename = '.project_id'
    if File.exist?(project_id_filename)
      @project_id_filename ||= File.read(project_id_filename)
    else
      puts "Please create a file called '#{project_id}'"
      puts "containing the Pivotal Tracker project number."
      exit 1
    end
  end

  # Changes a story's state to **Accepted**.
  def accept!(story_id)
    api = 'http://www.pivotaltracker.com/services/v3'
    story_uri = URI.parse("#{api}/projects/#{project_id}/stories/#{story_id}")
    accepted = "<story><current_state>accepted</current_state></story>"
    data =  { 'X-TrackerToken' => api_token,
              'Content-type' => "application/xml" }
    Net::HTTP.start(story_uri.host, story_uri.port) do |http|
      http.put(story_uri.path, accepted, data)
    end
  end

  def run!
    if story_branch != 'master' && !options['override']
      puts "Runs only on the master branch by default"
      puts "Use --override to override"
      exit 1
    end
    ids_to_accept.each { |id| accept!(id) }
  end
end