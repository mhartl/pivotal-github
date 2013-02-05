require 'spec_helper'

describe Record do

  subject { Record.new(['-a']) }

  it { should respond_to(:cmd) }
  it { should respond_to(:args) }
  it { should respond_to(:parse) }

  describe "with only known options" do
    
    let(:command) { Record.new(['-m', 'message', '-a']) }
    
    describe "parse" do
      subject { command.parse }

      its(:message) { should == 'message' }
      its(:all)     { should be_true }
    end
  end

  describe "with some unknown options" do
    let(:command) { Record.new(['-m', 'message', '-a', '-z', '--foo']) }
    
    it "should not raise an error" do
      expect { command.parse }.not_to raise_error(OptionParser::InvalidOption)
    end

    describe "parse" do
      subject { command.parse }

      its(:message) { should == 'message' }
      its(:all)     { should be_true }
    end
  end
end