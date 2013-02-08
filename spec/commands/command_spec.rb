require 'spec_helper'

describe Command do
  let(:command) { Command.new }
  before { command.stub(:current_branch).and_return('6283185-tau-manifesto') }
  subject { command }

  it { should respond_to(:cmd) }
  it { should respond_to(:args) }
  it { should respond_to(:options) }
  it { should respond_to(:parse) }
  it { should respond_to(:story_id) }
end