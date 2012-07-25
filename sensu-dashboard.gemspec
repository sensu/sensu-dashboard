# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sensu-dashboard/version"

Gem::Specification.new do |s|
  s.name        = "sensu-dashboard"
  s.version     = Sensu::Dashboard::VERSION
  s.authors     = ["Justin Kolberg", "Sean Porter"]
  s.email       = ["justin.kolberg@sonian.net", "portertech@gmail.com"]
  s.homepage    = "https://github.com/sonian/sensu-dashboard"
  s.summary     = %q{A web interface for sensu, a publish/subscribe server monitoring framework}
  s.description = %q{Display current events and clients in sensu via a simple web interface}

  s.add_dependency("sensu", "~> 0.9.6")
  s.add_dependency("em-http-request", "1.0.1")
  s.add_dependency("sass")

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
