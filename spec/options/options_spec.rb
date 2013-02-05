require 'spec_helper'

describe "foo" do
  it "should description" do
    Pivotal::Github::VERSION.should == '0.0.2'
  end
end