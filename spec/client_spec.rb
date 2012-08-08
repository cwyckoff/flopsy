require 'spec_helper'

module Flopsy
  describe Client do 

    before(:each) do
      Flopsy::Environment.reset
    end
    
    describe ".reset" do

      it "sets cached client to nil" do
        #when
        Environment.mode = :development
        client = Client.get

        # expect
        Client.cached.should_not be_nil

        # when
        Client.reset

        #expect
        Client.cached.should be_nil
      end

    end

    describe ".get" do

      it "returns a Bunny object" do
        Client.get.should be_an_instance_of(Bunny::Client)
      end

      it "returns a Bunny object with established connection to broker" do
        # given
        client = Client.get

        # expect
        client.connected?.should be_true
      end

      context "cached client exists" do

        it "returns a cached client" do
          # given
          original, cached = Client.get, Client.get

          # expect
          original.object_id.should == cached.object_id
        end

      end

      context "cached client does not exist" do

        it "returns a new client" do
          #given
          Client.reset

          #expect
          Client.get.should be_an_instance_of(Bunny::Client)
        end
        
        it "caches the new client" do
          #given
          Client.reset

          #when
          Client.get

          #expect
          Client.cached.should_not be_nil
        end
      end

      context "cached client looses connection" do

        before(:each) do
          @client = Client.get
          @client.stop
        end
        
        it "captures exception and creates a new connection" do
          #when
          new_client = Client.get

          #expect
          @client.object_id.should_not == new_client.object_id
        end

        it "caches new connection" do
          #when
          Client.get

          #expect
          Client.cached.should_not be_nil
        end

      end
      
    end

    xit "uses options hash from Flopsy::Environment to when instantiating client" do
      # given
      bunny = Bunny.new
      Client.reset
      Flopsy::Environment.define do |e|
        e.host = "127.0.0.1"
        e.vhost = "/"
      end

      # when
      client = Client.get

      # expect
      client.host.should == "127.0.0.1"
      client.vhost.should == "/"
    end

    xit "merges Flopsy::Environment options with options passed in to constructor" do
      # given
      Client.reset
      Flopsy::Environment.define do |e|
        e.host = "bunny.com"
        e.vhost = "foo"
        e.user = "me"
        e.pass = "secret"
      end
      opts = {:port => "1234", :logging => true}
      
      # expect
      Bunny.should_receive(:new).with(Flopsy::Environment.options.merge(opts)).and_return(Bunny.new)

      # when
      client = Client.get(opts)
    end
  end
end
