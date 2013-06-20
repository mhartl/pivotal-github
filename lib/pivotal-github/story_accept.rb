require 'pivotal-github/command'
require 'git'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'pivotal-github/delivered'

class StoryAccept < Command
  include Delivered

  def parser
    OptionParser.new do |opts|
      opts.banner = "Usage: git story-accept [options]"
      opts.on("-o", "--override", "override master branch requirement") do |opt|
        self.options.override = opt
      end
      opts.on("-q", "--quiet", "suppress display of accepted story ids") do |opt|
        self.options.quiet = opt
      end
      opts.on("-a", "--all", "process all stories (entire log)") do |opt|
        self.options.all = opt
      end
      opts.on_tail("-h", "--help", "this usage guide") do
        puts opts.to_s; exit 0
      end
    end
  end

  # The story_id has a different meaning in this context, so raise an
  # error if it's called accidentally.
  def story_id
    raise 'Invalid reference to Command#story_id'
  end

  # Returns the ids to accept.
  # These ids are of the form [Delivers #<story id>] or
  # [Delivers #<story id> #<another story id>].
  def ids_to_accept
    n_commits = `git rev-list HEAD --count`
    Git.open('.').log(n_commits).inject([]) do |accept, commit|
      delivered_ids(commit.message).each do |commit_id|
        return accept if already_accepted?(commit_id) && !options.all
        accept << commit_id
        accept.uniq!
      end
      accept
    end
  end

  # Returns true if a story has already been accepted.
  def already_accepted?(story_id)
    data = { 'X-TrackerToken' => api_token,
             'Content-type' => "application/xml" }
    uri = story_uri(story_id)
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.path, data)
    end
    Nokogiri::XML(response.body).at_css('current_state').content == "accepted"
  end

  def api_token
    api_filename = '.api_token'
    if File.exist?(api_filename)
      @api_token ||= File.read(api_filename).strip
    else
      puts "Please create a file called '#{api_filename}'"
      puts "containing your Pivotal Tracker API token."
      add_to_gitignore('.api_token')
      exit 1
    end
  end

  def project_id
    project_id_filename = '.project_id'
    if File.exist?(project_id_filename)
      @project_id ||= File.read(project_id_filename).strip
    else
      puts "Please create a file called '.project_id'"
      puts "containing the Pivotal Tracker project number."
      add_to_gitignore('.project_id')
      exit 1
    end
  end

  # Adds a filename to the .gitignore file (if necessary).
  # This is put in as a security precaution, especially to keep the
  # Pivotal Tracker API key from leaking.
  def add_to_gitignore(filename)
    gitignore = '.gitignore'
    if File.exist?(gitignore)
      contents = File.read(gitignore)
      unless contents =~ /#{filename}/
        File.open(gitignore, 'a') { |f| f.puts(filename) }
        puts "Added #{filename} to .gitignore"
      end
    end
  end

  # Changes a story's state to **Accepted**.
  def accept!(story_id)
    accepted = "<story><current_state>accepted</current_state></story>"
    data =  { 'X-TrackerToken' => api_token,
              'Content-type'   => "application/xml" }
    uri = story_uri(story_id)
    Net::HTTP.start(uri.host, uri.port) do |http|
      http.put(uri.path, accepted, data)
    end
    puts "Accepted story ##{story_id}" unless options.quiet
  end

  def run!
    if story_branch != 'master' && !options['override']
      puts "Runs only on the master branch by default"
      puts "Use --override to override"
      exit 1
    end
    ids_to_accept.each { |id| accept!(id) }
  end

  private

    def api_base
      'http://www.pivotaltracker.com/services/v3'
    end

    def story_uri(story_id)
      uri = "#{api_base}/projects/#{project_id}/stories/#{story_id}"
      URI.parse(uri)
    end
end