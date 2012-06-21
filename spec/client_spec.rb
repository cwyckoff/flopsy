require 'spec_helper'

module Flopsy
  describe Client do 

    describe ".reset" do

      it "sets cached client to nil" do
        #when
        client = Client.get

        # expect
        Client.cache.should_not be_nil
        
        # when
        Client.reset

        #expect
        Client.cache.should be_nil
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
          original = Client.get
          cached = Client.get

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
          Client.cache.should_not be_nil
        end
      end
    end
  end
end
