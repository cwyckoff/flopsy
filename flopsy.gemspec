Gem::Specification.new do |s|
  s.name = %q{flopsy}
  s.version = "0.0.1"
  s.authors = ["Chris Wyckoff"]
  s.date = %q{2011-12-12}
  s.description = %q{A helpful wrapper for the Amqp::Bunny library}
  s.email = %q{cbwyckoff@gmail.com}
  s.rubyforge_project = %q{flopsy}
  s.has_rdoc = true
  s.extra_rdoc_files = [ "README.rdoc" ]
  s.rdoc_options = [ "--main", "README.rdoc" ]
  s.homepage = %q{http://github.com/cwyckoff/flopsy/tree/master}
  s.summary = %q{A wrapper for the Amqp::Bunny library.}
  s.files = ["LICENSE",
             "README.rdoc",
             "Rakefile",
             "flopsy.gemspec",
             "lib/flopsy.rb",
             "lib/bunny/logger.rb",
             "lib/bunny/filter.rb",
             "lib/bunny/environment.rb",
             "lib/bunny/exception_handler.rb",
             "lib/bunny/fake_client.rb",
             "lib/bunny/consumer.rb"]
  s.add_development_dependency('bunny', [">= 0"])
  s.add_development_dependency('rspec', [">= 0"])
  s.add_development_dependency('ruby-debug', [">= 0"])
end
