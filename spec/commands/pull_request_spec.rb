require 'spec_helper'

describe PullRequest do

  let(:command) { PullRequest.new }
  before { command.stub(:story_branch).and_return('6283185-tau-manifesto') }
  before do
    command.stub(:origin_uri).and_return('https://github.com/mhartl/foo')
  end
  subject { command }

  its(:cmd) { should == "open #{command.uri}" }

  # describe "command-line command" do
  #   subject { `bin/story-open --debug` }
  #   it { should =~ /open https:\/\/www.pivotaltracker.com\/story\/show/ }
  # end
end