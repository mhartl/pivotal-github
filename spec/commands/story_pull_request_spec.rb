require 'spec_helper'

describe StoryPullRequest do

  let(:command) { StoryPullRequest.new }
  before { command.stub(:story_branch).and_return('6283185-tau-manifesto') }
  before do
    command.stub(:origin_uri).and_return('https://github.com/mhartl/foo')
  end
  subject { command }

  its(:cmd) { should == "open #{command.uri}" }

  describe "command-line command" do
    subject { `bin/git-story-pull-request --debug` }
    it { should =~ /pull\/new/ }
    it { should_not =~ /\.git/ }
  end
end