module Env
  @@dependencies = []
  @@env          = {}

  class << self
    def dependencies
      @@dependencies
    end

    def [](key)
      return @@env[key] if dependencies.include? key
      raise EnvironmentError, "#{key} is not a declared depency, add it to your Envfile"
      @@env[key]
    end

    def export(key, value = nil)
      @@dependencies << key
      @@env[key] = value
    end

    def enforce
      class << ENV
        alias_method :get, :[]  
        alias_method :set, :[]= 

        def [](key)
          Env[key]
        end

        def []=(key, value)
          puts "muhaha #{key}"
          set(key)
        end
      end
    end
  end
end

class EnvironmentError < StandardError
end


describe Env, "::enforce" do
  before { Env.enforce }

  it "should not allow references to undeclared variables" do
    lambda { ENV['UNDECLARED_VARIABLE'] }.should raise_error(EnvironmentError)
  end 

  context "with uninitialized dependency FOO" do
    before do 
      Env.instance_eval do
        export 'FOO'
      end
    end

    it "should return nil for ENV['FOO']" do
      ENV['FOO'].should eql(nil)
    end
  end

  context "with initialized dependency FOO=bar" do
    before do 
      Env.instance_eval do
        export 'FOO', 'bar'
      end
    end

    it "should return 'bar' for ENV['FOO']" do
      ENV['FOO'].should eql('bar')
    end
  end
end
