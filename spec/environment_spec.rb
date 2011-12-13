require 'spec_helper'

describe Flopsy::Environment do

  before(:each) do
    Flopsy::Environment.reset
  end
  
  describe ".define" do
    
    it "yields self to allow for setting of config options" do
      # given
      Flopsy::Environment.define do |e|
        e.host = "localhost"
        e.user = "me"
        e.pass = "secret"
      end

      # expect
      Flopsy::Environment.options.should_not be_nil
    end
    
  end

  describe ".options" do
    
    it "returns options hash" do
      # given
      Flopsy::Environment.define do |e|
        e.host = "localhost"
        e.user = "me"
        e.pass = "secret"
      end

      # expect
      Flopsy::Environment.options.should == {:host => "localhost", :user => "me", :pass => "secret"}
    end
    
  end

  describe ".reset" do
    
    it "sets options hash to empty hash" do
      # given
      Flopsy::Environment.define do |e|
        e.host = "localhost"
        e.user = "me"
        e.pass = "secret"
      end

      # when
      Flopsy::Environment.reset
      
      # expect
      Flopsy::Environment.options.should be_empty
    end
    
  end

  describe ".set?" do
    
    it "returns true if options hash is populated" do
      # given
      Flopsy::Environment.define do |e|
        e.host = "localhost"
        e.user = "me"
        e.pass = "secret"
      end

      # expect
      Flopsy::Environment.set?.should be_true
    end
    
    it "returns false if options hash is empty" do
      # given
      Flopsy::Environment.reset

      # expect
      Flopsy::Environment.set?.should be_false
    end
    
  end

end
