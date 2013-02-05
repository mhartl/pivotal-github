require 'spec_helper'

describe Submit do

  let(:command) { Submit.new }

  before do
    command.stub(:current_branch).and_return('6283185-tau-manifesto')
    command.parse
  end

  subject { command }

  it { should respond_to(:cmd) }
  it { should respond_to(:args) }
  it { should respond_to(:options) }
  it { should respond_to(:parse) }
  it { should respond_to(:story_id) }
  it { should respond_to(:pull_request_branch) }

  its(:cmd) { should =~ /git push/ }

  # shared_examples "submit with known options" do
  #   subject { command }

  #   its(:message)  { should_not be_empty }
  #   its(:message?) { should be_true }
  #   its(:all?)     { should be_true }

  #   describe "parse" do
  #     subject { command.options }

  #     its(:message) { should == 'message' }
  #     its(:all)     { should be_true }
  #   end
  # end

  describe "with no options" do
    its(:pull_request_branch) { should == 'master' }
    its(:cmd) { should == "git push origin #{command.current_branch}" }
  end

  describe "with a branch option" do
    let(:command) { Submit.new(['-p', 'develop']) }
    its(:pull_request_branch) { should == 'develop' }
  end

  # describe "with only known options" do
  #   let(:command) { Record.new(['-m', 'message', '-a']) }
  #   it_should_behave_like "record with known options"
  # end

  # describe "with a compound argument" do
  #   let(:command) { Record.new(['-am', 'message']) }
  #   it_should_behave_like "record with known options"
  # end

  describe "with some unknown options" do
    let(:command) { Submit.new(['-p', 'develop', '-a', '-z', '--foo']) }
    
    # it_should_behave_like "record with known options"
    
    it "should not raise an error" do
      expect { command.parse }.not_to raise_error(OptionParser::InvalidOption)
    end
  end

  # describe "command with no story id" do
  #   before { command.stub(:current_branch).and_return('tau-manifesto') }
  #   its(:cmd) do
  #     should == %(git commit -a -m "message" -z --foo)
  #   end    
  # end
end