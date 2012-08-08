$LOAD_PATH.unshift(File.dirname(__FILE__) + "/..")

require 'lib/flopsy'
# require 'lib/flopsy/fake_client'
require 'rspec'
require 'json'

Flopsy.logger = Flopsy::Logger.new('spec/flopsy.log')
