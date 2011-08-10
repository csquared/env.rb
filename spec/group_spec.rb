require 'spec_helper'

shared_examples_for "handling groups" do
  it "should only be loaded when that group is loaded" do
    Env.load!
    lambda { ENV["URL"] }.should raise_error(EnvironmentError)
    Env.load! :test
    lambda { ENV["URL"] }.should_not raise_error(EnvironmentError)
    ENV['URL'].should == 'http://google.com'
  end

  it "should allow loading in one command" do
    Env.load! :default, 'test'
    lambda { ENV["URL"] }.should_not raise_error(EnvironmentError)
    ENV['URL'].should == 'http://google.com'
  end
end

describe Env, "groups" do
  context "passed as a parameter" do
    before do
      envfile(%{
        export 'URL', 'http://google.com', :group => :test
      })
    end

    it_should_behave_like "handling groups"
  end


=begin
  context "in block form" do
    before do
      envfile(%{
        group :test do
          export 'URL', 'http://google.com'
        end
      })
    end

    it_should_behave_like "handling groups"
  end
=end
end
