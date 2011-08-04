require_relative '../lib/env'

describe Env, 'uri support' do

  context "with a value FOO that is a URI" do
    URL = 'http://username:password@this.domain.example.com/path?var=val'

    before do
      Env.instance_eval do
        export 'FOO', URL
      end
      Env.enforce
    end

    it "should leave the original value unchanged" do
      ENV['FOO'].should == URL
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
