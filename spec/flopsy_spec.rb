# bunny_spec.rb

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Flopsy.new' call below to include
# the relevant arguments e.g. @b = Flopsy.new(:user => 'john', :pass => 'doe', :host => 'foobar')

require 'spec_helper'

describe Flopsy do

  before(:each) do
    Flopsy::Environment.reset
  end
  
  describe ".logger" do

    it "returns a Flopsy::Logger" do
      # given
      Flopsy.logger = Flopsy::Logger.new('spec/bunny.log')

      # expect
      Flopsy.logger.should be_an_instance_of(Flopsy::Logger)
    end

    it "raises a MissingLogger exception if logger is not set" do
      # given
      Flopsy.logger = nil

      # expect
      lambda {Flopsy.logger}.should raise_error(Flopsy::MissingLogger)
    end
    
  end

  describe ".logger=" do

    it "sets a Flopsy::Logger" do
      # when
      Flopsy.logger = Flopsy::Logger.new('spec/bunny.log')

      # expect
      Flopsy.logger.should be_an_instance_of(Flopsy::Logger)
    end
    
  end

  describe ".client" do

    it "returns a new bunny client" do
      Flopsy.client.should be_an_instance_of(Bunny::Client)
    end
    
  end

  describe ".exchange" do

    it "returns a new Flopsy exchange object" do
      Flopsy.exchange("foo").should be_an_instance_of(Bunny::Exchange)
    end
    
  end

  describe ".delete_queue" do

    it "deletes a specified queue" do
      # given
      Flopsy.queue(:a_new_queue)
      `rabbitmqctl list_queues`.should =~ /a_new_queue/

      # when
      Flopsy.delete_queue(:a_new_queue)

      # expect
      `rabbitmqctl list_queues`.should_not =~ /a_new_queue/
    end
    
  end

  describe ".queue" do

    it "returns a new Flopsy queue object" do
      Flopsy.queue("foo").should be_an_instance_of(Bunny::Queue)
    end
    
  end

  describe ".fanout_queue" do

    it "returns a new Flopsy queue object that is bound to a fanout exchange" do
      # given
      queue = Flopsy.fanout_queue("foos", "my_queue")
      Flopsy.publish("foos", "bar", :type => "fanout")

      # expect
      queue.pop[:payload].should == "bar"
    end
    
  end
  
  describe ".publish" do

    it "publishes a messages to a specified queue" do
      # when
      Flopsy.publish(:foo, "bar")
      sleep 1 

      # expect
      Flopsy.queue("foo").pop[:payload].should == "bar"
    end
    
    it "publishes a messages to an exchange if type is set to 'fanout'" do
      # given
      q1 = Flopsy.fanout_queue("foos", "queues1")
      q2 = Flopsy.fanout_queue("foos", "queues2")

      # when
      Flopsy.publish("foos", "bar", :type => "fanout")

      # expect
      q1.pop[:payload].should == "bar"
      q2.pop[:payload].should == "bar"
    end

    it "filters message" do
      # given
      msg = {"foo" => "bar"}
      Flopsy::Filter.define do |f|
        f.on_publish {|msg| msg.to_json}
        f.on_consume {|msg| JSON.parse(msg.to_json)}
      end

      # when
      Flopsy.publish("foo", msg)

      # expect
      filtered = Flopsy.queue("foo").pop[:payload]
      JSON.parse(filtered).should == msg
    end
    
  end

  before(:each) do
    Flopsy::Client.reset
    @b = Flopsy.client
  end
  
  it "should connect to an AMQP server" do
    @b.status.should == :connected
  end

  it "should be able to create and open a new channel" do
    # given
    c = @b.create_channel

    # expect
    c.number.should == 2
    c.should be_an_instance_of(Bunny::Channel)
    @b.channels.size.should == 3
    c.open.should == :open_ok
    @b.channel.number.should == 2 
  end
  
  it "should be able to switch between channels" do
    # expect
    @b.channel.number.should == 1

    # when
    @b.switch_channel(0)

    # expect
    @b.channel.number.should == 0
  end
  
  it "should raise an error if trying to switch to a non-existent channel" do
    lambda { @b.switch_channel(5) }.should raise_error(RuntimeError)
  end

  it "should be able to create an exchange" do
    # given
    exch = @b.exchange('test_exchange')

    # expect
    exch.should be_an_instance_of(Bunny::Exchange)
    exch.name.should == 'test_exchange'
    @b.exchanges.has_key?('test_exchange').should be(true)
  end

  it "should be able to create a queue" do
    # given
    q = @b.queue('test1')

    # expect
    q.should be_an_instance_of(Bunny::Queue)
    q.name.should == 'test1'
    @b.queues.has_key?('test1').should be(true)
  end

  # Current RabbitMQ has not implemented some functionality
  it "should raise an error if setting of QoS fails" do
    lambda { @b.qos(:global => true) }.should raise_error(Bunny::ForcedConnectionCloseError)
    @b.status.should == :not_connected
  end

  it "should be able to set QoS" do
    @b.qos.should == :qos_ok
  end
  
end
