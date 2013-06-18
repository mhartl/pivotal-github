require 'spec_helper'

describe StoryAccept do

  let(:command) { StoryAccept.new(['-o', '-a']) }
  before { command.stub(:story_branch).and_return('62831853-tau-manifesto') }
  subject { command }

  it { should respond_to(:ids_to_accept) }

  its(:ids_to_accept) { should_not be_empty }
  its(:ids_to_accept) { should include("51204529") }
  its(:ids_to_accept) { should include("50566173") }
  its(:ids_to_accept) { should include("50566167") }

  its(:api_token) { should_not be_empty }

  describe "accept!" do

    before do
      command.stub(:accept!)
    end

    it "should accept each id" do
      number_accepted = command.ids_to_accept.length
      command.should_receive(:accept!).exactly(number_accepted).times
      command.run!
    end
  end
end