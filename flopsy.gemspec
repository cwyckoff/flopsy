require File.expand_path(File.dirname(__FILE__) + '/lib/flopsy')

Gem::Specification.new do |s|
  s.name = %q{flopsy}
  s.version = Flopsy::VERSION
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
             "lib/flopsy/logger.rb",
             "lib/flopsy/filter.rb",
             "lib/flopsy/environment.rb",
             "lib/flopsy/exception_handler.rb",
             "lib/flopsy/client.rb",
             "lib/flopsy/fake_client.rb",
             "lib/flopsy/consumer.rb"]
  s.add_dependency('bunny', [">= 0"])
  s.add_development_dependency('rspec', [">= 0"])
  s.add_development_dependency('ruby-debug', [">= 0"])
end
