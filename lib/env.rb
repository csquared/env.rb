require "env/version"
require 'uri'
require 'forwardable'

class EnvironmentError < StandardError
end

module Env
  RACK   = %w{GEM_HOME TMPDIR HTTPS}
  HEROKU = %w{TMP TEMP} + RACK
  @@dependencies = []
  @@env          = {}
  @@enforced     = false

  class << self
    def [](key)
      _raise(key) unless dependencies.include? key 
      @@env[key]
    end

    def []=(key,value)
      _raise(key) unless dependencies.include? key 
      @@env[key] = uri?(value) ? proxify(value) : value
    end

    def export(key, value = nil)
      @@dependencies << key
      @@env[key] = uri?(value) ? proxify(value) : value
    end

    def import(key)
      if key.is_a? Symbol
        const_get(key.to_s.upcase).each { |key| import(key) }
      else
        export(key, ENV.get(key))  
      end
    end

    def load!
      @@enforced or Env.enforce
      eval File.read("Envfile") if File.exist?("Envfile")
      File.exist?("Envfile")
    end

    def unload
      @@enforced and Env.unenforce
      @@dependencies = []
      @@env = {}
    end

    def unenforce
      class << ENV
        alias_method :[], :get  
        alias_method :[]=, :set
      end
      @@enforced = false
    end

    def enforce
      class << ENV
        alias_method :get, :[]  
        alias_method :set, :[]= 

        def [](key)
          Env[key]
        end

        def []=(key, value)
          Env[key] = value
        end
      end
      @@enforced = true
    end

    private 
    def _raise(key)
      raise EnvironmentError, "#{key} is not a declared dependency, add it to your Envfile"
    end

    def uri?(value)
      value.to_s.match(/^\w+:\/\//)
    end

    def proxify(value)
      UriProxy.new(value)
    end

    def dependencies
      @@dependencies
    end
  end

  class UriProxy < BasicObject
    extend ::Forwardable
    def_delegators :@uri, :scheme, :user, :password, :host

    def initialize(uri)
      @original = uri
      @uri = ::URI.parse(uri)
    end

    def base_uri
      "#{@uri.scheme}://#{@uri.host}"
    end
    alias url base_uri

    def method_missing(method, *args, &block)
      @original.send(method, *args, &block) 
    end
  end
end
