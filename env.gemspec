# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "env/version"

Gem::Specification.new do |s|
  s.name        = "env"
  s.version     = Env::VERSION
  s.authors     = ["Chris Continanza"]
  s.email       = ["christopher.continanza@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Manage your ENV with ease}
  s.description = %q{Allows your to manage many ENV vars by declaring them as dependencies on ENV vars and then enforcing those dependencies.  Supports wrapping URIs with support methods.}

  s.rubyforge_project = "env.rb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
