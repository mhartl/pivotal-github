require 'spec_helper'

describe StoryCommit do

  let(:command) { StoryCommit.new(['-m', 'message', '-a', '-z', '--foo']) }
  before { command.stub(:story_branch).and_return('6283185-tau-manifesto') }
  subject { command }

  it { should respond_to(:message) }

  shared_examples "story-commit with known options" do
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
    it_should_behave_like "story-commit with known options"
  end

  describe "with a compound argument" do
    let(:command) { StoryCommit.new(['-am', 'message']) }
    it_should_behave_like "story-commit with known options"
  end

  describe "with some unknown options" do
    let(:command) { StoryCommit.new(['-m', 'message', '-a', '-z', '--foo']) }
    
    it_should_behave_like "story-commit with known options"
    
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

    describe "when used with branches containing multiple stories" do
      before do
        command.stub(:story_branch).and_return('6283185-tau-manifesto-3141592')
      end
      its(:cmd) do
        delivered_ids = '#6283185 #3141592'
        should == %(git commit -a -m "[#{delivered_ids}] message" -z --foo)
      end
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

    describe "when used with branches containing multiple stories" do
      before do
        command.stub(:story_branch).and_return('6283185-tau-manifesto-3141592')
      end
      its(:cmd) do
        delivered_ids = '#6283185 #3141592'
        should == %(git commit -m "[Finishes #{delivered_ids}] message")
      end
    end
  end

  describe "command with deliver flag" do
    let(:command) { StoryCommit.new(['-m', 'message', '-d']) }
    its(:cmd) do
      should == %(git commit -m "[Delivers ##{command.story_id}] message")
    end

    describe "when used with branches containing multiple stories" do
      before do
        command.stub(:story_branch).and_return('6283185-tau-manifesto-3141592')
      end
      its(:cmd) do
        delivered_ids = '#6283185 #3141592'
        should == %(git commit -m "[Delivers #{delivered_ids}] message")
      end
    end
  end

  describe "command with no story id" do
    before { command.stub(:story_branch).and_return('tau-manifesto') }
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