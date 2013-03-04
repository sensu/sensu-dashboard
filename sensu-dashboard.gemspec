$:.push File.expand_path("../lib", __FILE__)
require "sensu-dashboard/version"

Gem::Specification.new do |s|
  s.name        = "sensu-dashboard"
  s.version     = Sensu::Dashboard::VERSION
  s.authors     = ["Justin Kolberg", "Sean Porter"]
  s.email       = ["justin.kolberg@sonian.net", "portertech@gmail.com"]
  s.homepage    = "https://github.com/sensu/sensu-dashboard"
  s.summary     = "A web interface for Sensu, a monitoring framework that aims to be simple, malleable, and scalable."
  s.description = "A web interface for Sensu, a monitoring framework that aims to be simple, malleable, and scalable."

  s.add_dependency("sensu", "~> 0.9.7")
  s.add_dependency("em-http-request", "~> 1.0.1")
  s.add_dependency("sass")
  s.add_dependency("slim")
  s.add_dependency("sprockets")
  s.add_dependency("yui-compressor")
  s.add_dependency("coffee-script")
  s.add_dependency("handlebars_assets")
  s.add_dependency("less")

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
