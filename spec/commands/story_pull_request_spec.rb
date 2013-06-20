require 'spec_helper'

describe StoryPullRequest do

  let(:command) { StoryPullRequest.new }
  before { command.stub(:story_branch).and_return('62831853-tau-manifesto') }
  before do
    command.stub(:remote_location).
            and_return('https://github.com/mhartl/foo')
    command.stub(:delivered_ids).and_return(['62831853', '31415926'])
    command.stub(:write_pr_file).and_return('')
  end
  subject { command }

  its(:cmd) { should match /git pull-request/ }
  its(:commit_message) do
    should include '[Delivers #62831853]'
    should include '[Delivers #31415926]'
  end

  describe "command-line command" do
    subject { `bin/git-story-pull-request --debug` }
    it { should_not match /\.git/ }
    it { should match /git pull-request/ }
  end
end