require 'spec_helper'

describe Env, 'uri support' do
  context "with a value FOO that is not a URI" do
    before do
      envfile(%{
        export 'FOO', 'bar'
      })
      Env.load!
    end

    it "should not wrap it" do
      lambda { ENV['FOO'].scheme }.should raise_error(::NoMethodError)
    end
  end

  context "with a value FOO that is a URI" do
    URL = 'http://username:password@this.domain.example.com/path?var=val'

    before do
      envfile(%{
        export 'FOO', URL
      })
      Env.load!
    end

    it "should leave the original value unchanged" do
      ENV['FOO'].should == URL
    end

    it "should return scheme://host for #base_uri and #url" do
      ENV['FOO'].base_uri.should == 'http://this.domain.example.com'
      ENV['FOO'].url.should == 'http://this.domain.example.com'
    end

    it "should respond to #scheme with the scheme'" do
      ENV['FOO'].scheme.should == 'http'
    end

    it "should respond to #host with the host" do
      ENV['FOO'].host.should == 'this.domain.example.com'
    end

    it "should respond to #password with the password" do
      ENV['FOO'].password.should == 'password'
    end

    it "should respond to #user with the user" do
      ENV['FOO'].user.should == 'username'
    end
  end
end
