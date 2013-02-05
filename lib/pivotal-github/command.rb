class Command
  attr_accessor :args, :cmd, :options, :known_options, :unknown_options

  def initialize(args = [])
    self.args = args
  end

  def current_branch
    `git rev-parse --abbrev-ref HEAD`
  end

  def story_id
    current_branch.scan(/\d+/).first
  end

  def options
    @options ||= parse
  end
end