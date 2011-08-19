require 'spec_helper'

describe Env, '::load!' do
  after { Env.unload }

  context "with no Envfile" do
    it "should return false" do
      Env.load!.should be_false
    end
  end

  context "with a simple Envfile" do
    before do
      envfile(%{
        export 'FOO', 'bar'
      })
    end

    after { File.unlink('Envfile') }

    it "should return true" do
      Env.load!.should be_true
    end

    it "should load Envfile in this directory" do
      Env.load!
      Env.enforce
      ENV['FOO'].should == 'bar'
    end 
  end

  context "when passed a block" do
    before do
      envfile("")
      @name = nil
      Env.load! { |name| @name = name }
    end

    it "should not raise and error by default" do
      lambda { ENV['FOO'] }.should_not raise_error
    end

    it "should pass the undeclared depencdies's key to the block" do
      ENV['FOO']
      @name.should == 'FOO'
      ENV['bar']
      @name.should == 'bar'
    end
  end
end
