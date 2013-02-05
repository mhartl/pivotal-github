require 'spec_helper'

describe Record do

  subject { Record.new(['-a']) }

  it { should respond_to(:cmd) }
  it { should respond_to(:args) }
  it { should respond_to(:options) }
  it { should respond_to(:parse) }
  it { should respond_to(:all?) }
  it { should respond_to(:message) }

  shared_examples "record with known options" do
    let(:options) { command.parse }
    before { options }
    subject { command }

    its(:message) { should == 'message' }
    its(:all?)    { should be_true }

    describe "parse" do
      subject { options }

      its(:message) { should == 'message' }
      its(:all)     { should be_true }
    end
  end

  describe "with only known options" do
    let(:command) { Record.new(['-m', 'message', '-a']) }
    it_should_behave_like "record with known options"
  end

  describe "with a compound argument" do
    let(:command) { Record.new(['-am', 'message']) }
    it_should_behave_like "record with known options"
  end

  describe "with some unknown options" do
    let(:command) { Record.new(['-m', 'message', '-a', '-z', '--foo']) }
    
    it_should_behave_like "record with known options"
    
    it "should not raise an error" do
      expect { command.parse }.not_to raise_error(OptionParser::InvalidOption)
    end
  end
end