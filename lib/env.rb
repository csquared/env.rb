require "env/version"
require 'uri'
require 'forwardable'

class EnvironmentError < StandardError
end

unless defined? BasicObject
  class BasicObject
    instance_methods.each do |m|
      undef_method(m) if m.to_s !~ /(?:^__|^nil?$|^send$|^object_id$)/
    end
  end
end

module Env
  RACK   = %w{GEM_HOME TMPDIR HTTPS}
  HEROKU = %w{TMP TEMP} + RACK
  EXPORT_DEFAULTS = {:group => :default}

  class << self
    def init
      @@dependencies  = []
      @@env           = {}
      @@enforced      = false
      @@groups        = Hash.new { |hash, key| hash[key] = [] }
      @@default_group = :default
      @@callback      = nil
    end

    def [](key)
      _raise(key) unless dependencies.include? key 
      @@env[key]
    end

    def []=(key,value)
      _raise(key) unless dependencies.include? key 
      @@env[key] = uri?(value) ? proxify(value) : value
    end

    def group(name)
      @@default_group = name.to_sym
      yield
      @@default_group = :default
    end

    def export_defaults
      {:group => @@default_group}
    end

    #store actual work and load group
    def export(key, value = nil, options = {})
      options = export_defaults.merge!(options)
      @@groups[options[:group].to_sym] << lambda do
        @@dependencies << key
        @@env[key] = uri?(value) ? proxify(value) : value
      end
    end

    #only calls itself and export
    def import(key)
      if key.is_a? Symbol
        const_get(key.to_s.upcase).each { |key| import(key) }
      else
        export(key, ENV.get(key))  
      end
    end

    def load_groups(*groups)
      groups.each do |group|
        @@groups[group.to_sym].each { |c| c.call }
      end
    end

    def load!(*groups, &block)
      @@callback = block if block_given? 
      @@enforced or Env.enforce
      eval File.read("Envfile") if File.exist?("Envfile")
      groups = [:default] if groups.empty?
      load_groups(*groups)
      File.exist?("Envfile")
    end

    def unload
      @@enforced and Env.unenforce
      init
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
      return @@callback.call(key) if @@callback
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
    def_delegators :@uri, :scheme, :user, :password, :host, :port

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

Env.init
