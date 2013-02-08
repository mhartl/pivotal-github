require 'spec_helper'

describe StoryMerge do

  let(:command) { StoryMerge.new }
  before { command.stub(:story_branch).and_return('6283185-tau-manifesto') }
  subject { command }

  its(:cmd) { should =~ /git merge/ }

  shared_examples "story-merge with known options" do
    subject { command }
    it "should not raise an error" do
      expect { command.parse }.not_to raise_error(OptionParser::InvalidOption)
    end
  end

  describe "with no options" do
    its(:cmd) { should =~ /git checkout master/ }
    its(:cmd) { should =~ /git merge --no-ff #{command.story_branch}/ }
  end

  describe "with a custom development branch" do
    let(:command) { StoryPull.new(['-d', 'develop']) }
    its(:cmd) { should =~ /git checkout develop/ }
  end

  describe "with some unknown options" do
    let(:command) { StoryPull.new(['-d', 'develop', '-a', '-z', '--foo']) }
    it_should_behave_like "story-merge with known options"
    its(:cmd) { should =~ /git pull -a -z --foo/ }
  end

  describe "command-line command" do
    subject { `bin/git-story-merge --debug -ff -d develop` }
    it { should =~ /git checkout develop/ }
    it { should =~ /git merge --no-ff -ff/ }
  end
end