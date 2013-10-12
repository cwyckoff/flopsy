# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flopsy/version'

Gem::Specification.new do |s|
  s.name             = %q{flopsy}
  s.version          = Flopsy::VERSION
  s.authors          = ["Chris Wyckoff"]
  s.email            = %q{cbwyckoff@gmail.com}
  s.date             = %q{2011-12-12}
  s.description      = %q{A helpful wrapper for the Amqp::Bunny library}
  s.summary          = %q{A wrapper for the Amqp::Bunny library.}
  s.homepage         = %q{http://github.com/cwyckoff/flopsy/tree/master}

  s.has_rdoc         = true
  s.extra_rdoc_files = [ "README.rdoc" ]
  s.rdoc_options     = [ "--main", "README.rdoc" ]

  s.require_paths    = ['lib']
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "flopsy.gemspec",
    "lib/flopsy.rb",
    "lib/flopsy/client.rb",
    "lib/flopsy/consumer.rb",
    "lib/flopsy/environment.rb",
    "lib/flopsy/exception_handler.rb",
    "lib/flopsy/fake_client.rb",
    "lib/flopsy/filter.rb",
    "lib/flopsy/logger.rb",
    "lib/flopsy/version.rb",
  ]

  s.add_dependency 'bunny', '~> 0.8.0'

  s.add_development_dependency 'rspec',       '~> 2.14.0'
  s.add_development_dependency 'debugger',    '~>  1.6.1'
  s.add_development_dependency 'guard-rspec', '~>  3.0.2'
  s.add_development_dependency 'json',        '~>  1.8.0'
end
