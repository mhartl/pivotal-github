require 'spec_helper'

describe Command do
  let(:command) { Command.new }
  before { command.stub(:story_branch).and_return('6283185-tau-manifesto') }
  subject { command }

  it { should respond_to(:cmd) }
  it { should respond_to(:args) }
  it { should respond_to(:options) }
  it { should respond_to(:parse) }
  it { should respond_to(:story_ids) }
  its(:story_ids) { should eq ['6283185']}

  describe "branches with multiple stories" do
    before do
      command.stub(:story_branch).and_return('6283185-tau-manifesto-3141592')
    end
    its(:story_ids) { should eq ['6283185', '3141592'] }
  end
end