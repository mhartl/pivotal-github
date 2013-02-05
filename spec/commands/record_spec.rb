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
end