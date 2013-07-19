require 'spec_helper'

describe ProjectOpen do

  let(:command) { ProjectOpen.new }

  it "should have a working project_url" do
    expect { command.project_url }.not_to raise_error
  end

  context "with stubbed-out project_id" do
    let(:project_id) { '6283185' }
    before { command.stub(:project_id).and_return(project_id) }
    let(:uri) { "https://www.pivotaltracker.com/projects/#{project_id}" }
    subject { command }

    its(:cmd) { should eq "open #{uri}" }
  end
end