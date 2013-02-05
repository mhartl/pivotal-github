require 'spec_helper'
require 'ostruct'

describe Options do

  let(:options) { OpenStruct.new }

  let(:parser) do
    OptionParser.new do |opts|
      opts.banner = "Usage: git record [options]"
      opts.on("-m", "--message MESSAGE",
              "add a commit message (with ticket #)") do |m| 
        options.message = m
      end
      opts.on("-a", "--all", "commit all changed files") do |a|
        options.all = a
      end
      opts.on("-f", "--finish", "mark story as finished") do |f|
        options.finish = f
      end
      opts.on_tail("-h", "--help", "this usage guide") do
        puts opts.to_s; exit 0
      end
    end    
  end

  let(:args) { ['-a', '-m', '"A message"', '--finish', '-z', '--foo', 'b ar'] }

  it { should respond_to(:unknown_options) }

  describe '#unknown_options' do
    subject { Options::unknown_options(parser, args) }

    it { should include('-z') }
    it { should include('--foo') }
    it { should include('b ar') }
  end
end