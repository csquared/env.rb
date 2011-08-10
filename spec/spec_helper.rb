require_relative '../lib/env'

def envfile(string)
  File.open("Envfile", 'w') do |f|
    f << string
  end
end

RSpec.configure do |config|
  config.after(:each) { Env.unload }
end
