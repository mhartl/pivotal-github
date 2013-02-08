require 'spec_helper'

describe StoryPull do

  let(:command) { StoryPull.new }
  before { command.stub(:story_branch).and_return('6283185-tau-manifesto') }
  subject { command }

  its(:cmd) { should =~ /git pull/ }

  shared_examples "story-pull with known options" do
    subject { command }
    it "should not raise an error" do
      expect { command.parse }.not_to raise_error(OptionParser::InvalidOption)
    end
  end

  describe "with no options" do
    its(:cmd) { should =~ /git checkout master/ }
    its(:cmd) { should =~ /git pull/ }
    its(:cmd) { should =~ /git checkout #{command.story_branch}/ }
  end

  describe "with a target option" do
    let(:command) { StoryPull.new(['-d', 'develop']) }
    its(:cmd) { should =~ /git checkout develop/ }
  end

  describe "with some unknown options" do
    let(:command) { StoryPull.new(['-d', 'develop', '-a', '-z', '--foo']) }
    it_should_behave_like "story-pull with known options"
    its(:cmd) { should =~ /git pull -a -z --foo/ }
  end

  # describe "command-line command" do
  #   subject { `bin/git-story-pull --debug -z -t heroku` }
  #   it { should =~ /git pull -z heroku/ }
  # end
end