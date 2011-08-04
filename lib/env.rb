require "env/version"

class EnvironmentError < StandardError
end

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
