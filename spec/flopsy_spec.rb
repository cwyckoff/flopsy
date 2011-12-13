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
  
  describe ".new_bunny" do
    
    it "returns an instance of FakeClient if Flopsy::Environment.mode is set to :test" do
      # given
      Flopsy::Environment.mode = :test

      # expect
      Flopsy.new_bunny.should be_an_instance_of(Flopsy::FakeClient)
    end
    
    it "uses options hash from Flopsy::Environment to when instantiating client" do
      # given
      Flopsy::Environment.define do |e|
        e.host = "bunny.com"
        e.vhost = "foo"
        e.user = "me"
        e.pass = "secret"
      end

      # when
      client = Flopsy.new_bunny

      # expect
      client.host.should == "bunny.com"
      client.vhost.should == "foo"
    end
    
    it "uses options hash passed in to constructor if Flopsy::Environment not set" do
      # when
      client = Flopsy.new_bunny(:host => "wabbit.com", :vhost => "bar")

      # expect
      client.host.should == "wabbit.com"
      client.vhost.should == "bar"
    end
    
    it "merges Flopsy::Environment options with options passed in to constructor" do
      # given
      Flopsy::Environment.define do |e|
        e.host = "bunny.com"
        e.vhost = "foo"
        e.user = "me"
        e.pass = "secret"
      end

      # when
      client = Flopsy.new_bunny(:port => "1234", :logging => true)

      # expect
      client.host.should == "bunny.com"
      client.vhost.should == "foo"
      client.port.should == "1234"
    end
    
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
      Flopsy.publish("foo", "bar")

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
    @b = Flopsy.new_bunny
    @b.start
  end
  
  it "should connect to an AMQP server" do
    @b.status.should == :connected
  end

  it "should be able to create and open a new channel" do
    c = @b.create_channel
    c.number.should == 2
    c.should be_an_instance_of(Bunny::Channel)
    @b.channels.size.should == 3
    c.open.should == :open_ok
    @b.channel.number.should == 2 
  end
  
  it "should be able to switch between channels" do
    @b.channel.number.should == 1
    @b.switch_channel(0)
    @b.channel.number.should == 0
  end
  
  it "should raise an error if trying to switch to a non-existent channel" do
    lambda { @b.switch_channel(5) }.should raise_error(RuntimeError)
  end

  it "should be able to create an exchange" do
    exch = @b.exchange('test_exchange')
    exch.should be_an_instance_of(Bunny::Exchange)
    exch.name.should == 'test_exchange'
    @b.exchanges.has_key?('test_exchange').should be(true)
  end

  it "should be able to create a queue" do
    q = @b.queue('test1')
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
