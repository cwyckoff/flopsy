$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bunny'
require 'lib/flopsy'

num = ARGV[0]
Flopsy.logger = Flopsy::Logger.new('spec/flopsy.log')

class MessageHandler
  attr_reader :messages
  
  def initialize(consumer_id)
    @consumer_id, @messages = consumer_id, []
  end
  
  def process(msg)
    File.open("spec/support/consumer#{@consumer_id}.txt", "w") do |f|
      f << "received message: '#{msg}'"
    end
  end
  
end

opts = {
  :type => "fanout",
  :exch_name => "consumer_exchange"
}

Flopsy::Consumer.start("fanout_queue#{num}", MessageHandler.new(num), opts)
