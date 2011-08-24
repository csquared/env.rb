unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require_relative '../lib/env'

def envfile(string)
  File.open("Envfile", 'w') do |f|
    f << string
  end
end

RSpec.configure do |config|
  config.after(:each) { Env.unload }
  config.after(:each) { File.unlink("Envfile") if File.exist?("Envfile")}
end
