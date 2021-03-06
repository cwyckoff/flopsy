require 'spec_helper'
require 'json'

describe Flopsy::Filter do

  before(:each) do
    Flopsy::Filter.reset
  end
  
  describe ".define" do
    
    it "yields self to allow for setting of config options" do
      # given
      msg = {"foo" => "bar"}
      Flopsy::Filter.define do |f|
        f.on_publish {|msg| msg.to_json}
        f.on_consume {|msg| JSON.parse(msg)}
      end

      # expect
      Flopsy::Filter.filter_actions[:publish].should be_a_kind_of(Proc)
      Flopsy::Filter.filter_actions[:consume].should be_a_kind_of(Proc)
    end
    
  end

  describe ".reset" do
    
    it "sets filter actions to nil" do
      # given
      msg = {"foo" => "bar"}
      Flopsy::Filter.define do |f|
        f.on_publish {|msg| msg.to_json}
        f.on_consume {|msg| JSON.parse(msg)}
      end

      # when
      Flopsy::Filter.reset

      # expect
      Flopsy::Filter.filter_actions.should be_empty
    end
    
  end

  describe ".on_publish" do
    
    it "sets 'publish' filter action" do
      # given
      msg = {"foo" => "bar"}
      Flopsy::Filter.on_publish {|msg| msg.to_json}

      # expect
      Flopsy::Filter.filter_actions[:publish].should be_a_kind_of(Proc)
    end
    
  end

  describe ".on_consume" do
    
    it "sets 'publish' filter action" do
      # given
      msg = {"foo" => "bar"}
      Flopsy::Filter.on_consume {|msg| JSON.parse(msg)}

      # expect
      Flopsy::Filter.filter_actions[:consume].should be_a_kind_of(Proc)
    end
    
  end

  describe ".filter" do
    
    it "calls filter proc for filter action" do
      # given
      msg = {"foo" => "bar"}
      Flopsy::Filter.define do |f|
        f.on_publish {|msg| msg.to_json}
        f.on_consume {|msg| JSON.parse(msg.to_json)}
      end

      # expect
      Flopsy::Filter.filter(:publish, msg).should == msg.to_json
      Flopsy::Filter.filter(:consume, msg).should == msg
    end
    
    it "returns message if no filter is set for action" do
      # given
      msg = {"foo" => "bar"}
      Flopsy::Filter.reset

      # expect
      Flopsy::Filter.filter(:publish, msg).should == msg
      Flopsy::Filter.filter(:consume, msg).should == msg
    end
    
  end
end
