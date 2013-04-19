require 'spec_helper'

describe StoryPullRequest do

  let(:command) { StoryPullRequest.new }
  before { command.stub(:story_branch).and_return('6283185-tau-manifesto') }
  before do
    command.stub(:remote_location).
            and_return('https://github.com/mhartl/foo')
  end
  subject { command }

  its(:cmd) { should =~ /open #{command.uri}/ }
  its(:cmd) { should =~ /git story-push/ }

  describe 'origin uri parsing' do
    let(:correct_origin) { 'https://github.com/mhartl/foo' }
    subject { command.send :origin_uri }

    context 'https protocol' do
      it { should eq correct_origin }
    end

    context 'git protocol' do
      before do
        command.stub(:remote_location).
                and_return('git@github.com:mhartl/foo')
      end

      it { should eq correct_origin }
    end
  end

  describe "command-line command" do
    subject { `bin/git-story-pull-request --debug` }
    it { should =~ /pull\/new/ }
    it { should_not =~ /\.git/ }
    it { should =~ /git story-push/ }

    describe "with a skip option" do
      subject { `bin/git-story-pull-request --skip --debug` }
      it { should_not =~ /git story-push/ }
    end
  end
end