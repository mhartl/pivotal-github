require 'spec_helper'

describe Story do
  include Story

  describe '#story_url' do
    let(:id) { '62831853' }
    subject { story_url(id) }
    it { should include id }
  end

  describe '#delivered_ids_since_last_pr' do
    let(:text) do <<-EOS
      [Delivers #62831853 #31415926]
      [Delivered #27182818]

      [Delivers #55203510](https://www.pivotaltracker.com/story/show/55203510)
      [Delivers #55202656](https://www.pivotaltracker.com/story/show/55202656)

      [Delivers #55202656]
      EOS
    end
    subject { delivered_ids_since_last_pr(text) }

    it { should include '62831853' }
    it { should include '31415926' }
    it { should include '27182818' }
    it { should_not include '55203510' }
    it { should_not include '55202656' }
  end
end