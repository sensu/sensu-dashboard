# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'lib', 'sensu-dashboard', 'constants')

Gem::Specification.new do |s|
  s.name        = "sensu-dashboard"
  s.version     = Sensu::Dashboard::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Justin Kolberg", "Sean Porter"]
  s.email       = ["justin.kolberg@sonian.net", "portertech@gmail.com"]
  s.homepage    = "https://github.com/sensu/sensu-dashboard"
  s.summary     = "A web interface for Sensu, a monitoring framework that aims to be simple, malleable, and scalable."
  s.description = "A web interface for Sensu, a monitoring framework that aims to be simple, malleable, and scalable."
  s.license     = "MIT"
  s.has_rdoc    = false

  s.add_dependency('sensu', '>= 0.9.12')
  s.add_dependency('em-http-request', '~> 1.0.1')
  s.add_dependency('sass')
  s.add_dependency('slim')
  s.add_dependency('sprockets')
  s.add_dependency('yui-compressor')
  s.add_dependency('coffee-script')
  s.add_dependency('handlebars_assets')
  s.add_dependency('therubyracer', '0.11.4')
  s.add_dependency('less')
  s.add_dependency('sinatra', '1.3.5')

  s.files         = Dir.glob('{bin,lib}/**/*') + %w[sensu-dashboard.gemspec README.md CHANGELOG.md MIT-LICENSE.txt]
  s.executables   = Dir.glob('bin/**/*').map { |file| File.basename(file) }
  s.require_paths = ['lib']
end
