require 'spec_helper'

describe StoryPush do

  let(:command) { StoryPush.new }
  before { command.stub(:current_branch).and_return('6283185-tau-manifesto') }
  subject { command }

  its(:cmd) { should =~ /git push/ }

  shared_examples "story-push with known options" do
    subject { command }
    it "should not raise an error" do
      expect { command.parse }.not_to raise_error(OptionParser::InvalidOption)
    end
  end

  describe "with no options" do
    its(:cmd) { should == "git push origin #{command.current_branch}" }
  end

  describe "with a target option" do
    let(:command) { StoryPush.new(['-t', 'heroku']) }
    its(:cmd) { should =~ /git push heroku/ }
  end

  describe "with some unknown options" do
    let(:command) { StoryPush.new(['-p', 'develop', '-a', '-z', '--foo']) }
    it_should_behave_like "story-push with known options"
    its(:cmd) { should =~ /-a -z --foo/ }
  end

  describe "command-line command" do
    subject { `bin/git-story-push --debug -z -t heroku` }
    it { should =~ /git push -z heroku/ }
  end
end