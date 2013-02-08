require 'spec_helper'

describe StoryCommit do

  before { command.stub(:current_branch).and_return('6283185-tau-manifesto') }
  let(:command) { StoryCommit.new(['-m', 'message', '-a', '-z', '--foo']) }
  subject { command }

  it { should respond_to(:cmd) }
  it { should respond_to(:args) }
  it { should respond_to(:options) }
  it { should respond_to(:parse) }
  it { should respond_to(:message) }
  it { should respond_to(:story_id) }

  shared_examples "record with known options" do
    subject { command }

    its(:cmd)      { should =~ /git commit/ }
    its(:message)  { should_not be_empty }
    its(:message?) { should be_true }
    its(:all?)     { should be_true }

    describe "parse" do
      subject { command.options }

      its(:message) { should == 'message' }
      its(:all)     { should be_true }
    end
  end

  describe "with only known options" do
    let(:command) { StoryCommit.new(['-m', 'message', '-a']) }
    it_should_behave_like "record with known options"
  end

  describe "with a compound argument" do
    let(:command) { StoryCommit.new(['-am', 'message']) }
    it_should_behave_like "record with known options"
  end

  describe "with some unknown options" do
    let(:command) { StoryCommit.new(['-m', 'message', '-a', '-z', '--foo']) }
    
    it_should_behave_like "record with known options"
    
    it "should not raise an error" do
      expect { command.parse }.not_to raise_error(OptionParser::InvalidOption)
    end
  end

  describe '#story_id' do
    subject { command.story_id }
    it { should == '6283185' }
  end

  describe "command with message" do
    its(:cmd) do
      should == %(git commit -a -m "[##{command.story_id}] message" -z --foo)
    end
  end

  describe "command with no message" do
    let(:command) { StoryCommit.new(['-a', '-z', '--foo']) }
    its(:cmd) { should == %(git commit -a -z --foo) }      
  end

  describe "command with finish flag" do
    let(:command) { StoryCommit.new(['-m', 'message', '-f']) }
    its(:cmd) do
      should == %(git commit -m "[Finishes ##{command.story_id}] message")
    end      
  end

  describe "command with deliver flag" do
    let(:command) { StoryCommit.new(['-m', 'message', '-d']) }
    its(:cmd) do
      should == %(git commit -m "[Delivers ##{command.story_id}] message")
    end
  end

  describe "command with no story id" do
    before { command.stub(:current_branch).and_return('tau-manifesto') }
    its(:cmd) do
      should == %(git commit -a -m "message" -z --foo)
    end    
  end

  describe "command-line command" do
    let(:command) { `bin/git-story-commit -a -m "message" -z --debug` }
    subject { command }
    it { should =~ /git commit -a -m/ }
    it { should =~ /message/ }
    it { should =~ /-z/ }
    it { should_not =~ /--debug/ }
  end
end