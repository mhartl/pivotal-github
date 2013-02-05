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

  its(:cmd) { should =~ /git push/ }

  shared_examples "submit with known options" do
    subject { command }
    it "should not raise an error" do
      expect { command.parse }.not_to raise_error(OptionParser::InvalidOption)
    end
  end

  describe "with no options" do
    its(:pull_request_branch) { should == 'master' }
    its(:cmd) { should == "git push origin #{command.current_branch}" }
  end

  describe "with a branch option" do
    let(:command) { Submit.new(['-p', 'develop']) }
    its(:pull_request_branch) { should == 'develop' }
  end

  describe "with a target option" do
    let(:command) { Submit.new(['-t', 'heroku']) }
    its(:cmd) { should =~ /git push heroku/ }
  end

  describe "with some unknown options" do
    let(:command) { Submit.new(['-p', 'develop', '-a', '-z', '--foo']) }
    it_should_behave_like "submit with known options"
    its(:cmd) { should =~ /-a -z --foo/ }
  end
end