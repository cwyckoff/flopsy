# consumer_spec.rb

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Bunny.new' call below to include
# the relevant arguments e.g. @b = Bunny.new(:user => 'john', :pass => 'doe', :host => 'foobar')

require 'spec_helper'
require 'json'

class MessageHandler
  attr_reader :messages, :id
  
  def initialize(id=1)
    @id = id
    @messages = []
  end
  
  def process(msg)
    @messages << msg
  end
  
end

module Flopsy
  describe Consumer do

    describe ".consume" do

      before(:each) do
        Flopsy::Environment.reset
        Filter.reset
      end
      
      it "subscribes to a queue bound to a direct exchange if type is nil or type is not 'fanout'" do
        # given
        q = Flopsy.queue("consumer_queue")
        q.publish("hello")
        q.message_count.should == 1

        # when
        Flopsy::Consumer.start("consumer_queue", MessageHandler.new, :timeout => 2)

        # expect
        q.message_count.should == 0
      end
      
      it "subscribes to a queue bound to a fanout exchange if type is 'fanout'" do
        # given
        Dir["spec/support/consumer*.txt"].each { |file| File.delete(file) }
        
        # when
        Flopsy.publish("consumer_exchange", "hello to all", :type => "fanout")

        # expect
        sleep 2
        File.read("spec/support/consumer1.txt").should == "received message: 'hello to all'"
        File.read("spec/support/consumer2.txt").should == "received message: 'hello to all'"
      end

      it "filters message" do
        # given
        Filter.define { |f| f.on_consume {|msg| JSON.parse(msg)} }
        handler = MessageHandler.new
        q = Flopsy.queue("consumer_queue")
        q.publish({"foo" => "bar"}.to_json)

        # expect
        q.message_count.should == 1

        # when
        Flopsy::Consumer.start("consumer_queue", handler, :timeout => 2)

        # expect
        handler.messages.first.should == {"foo" => "bar"}
      end
    end
  end
end
