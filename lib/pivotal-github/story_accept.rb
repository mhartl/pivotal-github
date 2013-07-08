require 'pivotal-github/command'
require 'pivotal-github/story'
require 'nokogiri'
require 'net/http'
require 'cgi'

class StoryAccept < Command
  include Story

  def parser
    OptionParser.new do |opts|
      opts.banner = "Usage: git story-accept [options]"
      opts.on("-o", "--override", "override master branch requirement") do |opt|
        self.options.override = opt
      end
      opts.on("-q", "--quiet", "don't display accepted story ids") do |opt|
        self.options.quiet = opt
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
  # The stories to accept are the set intersection of the delivered stories
  # according to the Git log and according to Pivotal Tracker.
  def ids_to_accept
    git_log_delivered_story_ids & pivotal_tracker_delivered_story_ids
  end

  # Returns the ids of delivered stories according to the Git log.
  # These ids are of the form [Delivers #<story id>] or
  # [Delivers #<story id> #<another story id>]. The difference is handled
  # by the delivered_ids method.
  def git_log_delivered_story_ids
    delivered_text = `git log -E --grep '\\[Deliver(s|ed) #'`
    delivered_ids(delivered_text).uniq
  end

  def pivotal_tracker_ids(filter)
    uri = URI.parse("#{project_uri}/stories?filter=#{CGI::escape(filter)}")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri, data)
    end
    Nokogiri::XML(response.body).css('story > id').map(&:content)
  end

  # Returns the ids of delivered stories according to Pivotal Tracker.
  # We include 'includedone:true' to force Pivotal Tracker to return
  # *all* delivered ids, no matter when the story was finished. This also
  # appears to be necessary to return the ids of stories marked **Delivered**
  # by a merge commit, as in `git story-merge -d`.
  def pivotal_tracker_delivered_story_ids
    pivotal_tracker_ids('state:delivered includedone:true')
  end

  # Returns true if a story has already been accepted.
  def already_accepted?(story_id)
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.path, data)
    end
    Nokogiri::XML(response.body).at_css('current_state').content == "accepted"
  end

  def config_filename(filename, description)
    if File.exist?(filename)
      add_to_gitignore(filename)
      varname = '@' + filename.sub('.', '')
      value = File.read(filename).strip
      instance_variable_set(varname, value)
    else
      puts "Please create a file called '#{filename}'"
      puts "containing #{description}."
      add_to_gitignore(filename)
      exit 1
    end
  end

  def api_token
    config_filename('.api_token', 'your Pivotal tracker API token')
  end

  def project_id
    config_filename('.project_id', 'the Pivotal tracker project id')
  end

  # Adds a filename to the .gitignore file (if necessary).
  # This is put in as a security precaution, especially to keep the
  # Pivotal Tracker API key from leaking.
  def add_to_gitignore(filename)
    gitignore = '.gitignore'
    if File.exist?(gitignore)
      contents = File.read(gitignore)
      unless contents =~ /#{filename}/
        # Prepend a newline if the file doesn't end in a newline.
        line = contents == contents.chomp ? "\n#{filename}" : filename
        File.open(gitignore, 'a') { |f| f.puts(line) }
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

    def project_uri
      URI.parse("#{api_base}/projects/#{project_id}")
    end

    def story_uri(story_id)
      URI.parse("#{project_uri}/stories/#{story_id}")
    end

    # Returns data for Pivotal Tracker API calls
    def data
      { 'X-TrackerToken' => api_token,
        'Content-type'   => "application/xml" }
    end
end