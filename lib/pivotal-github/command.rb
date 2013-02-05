class Command
  attr_accessor :args, :cmd, :options

  def initialize(args)
    self.args = args
  end

  def current_branch
    `git symbolic-ref HEAD`.chomp.split('/').last
  end

  def story_id
    current_branch.scan(/\d+/).first
  end
end