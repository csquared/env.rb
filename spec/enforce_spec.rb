require 'spec_helper'

describe Env, "::enforce" do
  before { Env.enforce }

  it "should not allow references to undeclared variables" do
    lambda { ENV['UNDECLARED_VARIABLE'] }.should raise_error(EnvironmentError)
  end 

  context "with uninitialized dependency FOO" do
    before do 
      envfile(%{
        export 'FOO'
      })
      Env.load!
    end

    it "should return nil for ENV['FOO']" do
      ENV['FOO'].should eql(nil)
    end

    it "should allow you to set it" do
      ENV['FOO'] = 'bar'
      ENV['FOO'].should eql('bar')
    end
  end

  context "with initialized dependency FOO=bar" do
    before do 
      envfile(%{
        export 'FOO', 'bar'
      })
      Env.load!
    end

    it "should return 'bar' for ENV['FOO']" do
      ENV['FOO'].should eql('bar')
    end
  end
end
