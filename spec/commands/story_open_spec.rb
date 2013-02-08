require 'spec_helper'

describe StoryOpen do

  let(:command) { StoryOpen.new }
  let(:uri) { "https://www.pivotaltracker.com/story/show/#{command.story_id}" }
  before { command.stub(:story_branch).and_return('6283185-tau-manifesto') }
  subject { command }

  its(:cmd) { should == "open #{uri}" }

  describe "command-line command" do
    subject { `bin/story-open --debug` }
    it { should =~ /open https:\/\/www.pivotaltracker.com\/story\/show/ }
  end
end