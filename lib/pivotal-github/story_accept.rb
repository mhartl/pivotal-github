require 'pivotal-github/command'
require 'git'

class StoryAccept < Command

  def parser
    OptionParser.new do |opts|
      opts.banner = "Usage: git story-accept"
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
    messages  = Git.open('.').log.map(&:message)
    delivered = messages.join.scan(delivered_regex).flatten
    delivered.inject([]) do |ids, element|
      ids.concat(element.scan(/[0-9]{8,}/).flatten)
      ids
    end
  end

  def run!
    # Get Pivotal API key, if necessary
    # Iterate through the delivered story ids, marking as accepted
  end

  private
end