require 'spec_helper'

describe Flopsy::ExceptionHandler do

  before(:each) do
    Flopsy::ExceptionHandler.reset
  end
  
  describe ".define" do
    
    it "yields self for registering of exceptions" do
      # given
      msg = {:foo => "bar"}
      Flopsy::ExceptionHandler.define do |h|
        h.register(:all) do |exception, info|
          Flopsy.logger.info("something blew up: #{exception.message}")
        end
      end

      # expect
      Flopsy::ExceptionHandler.handlers[:all].first.should be_a_kind_of(Proc)
    end

  end

  describe ".register" do

    before(:each) do
      msg = {:foo => "bar"}
      Flopsy::ExceptionHandler.define do |h|
        h.register(:publish) do |exception, info|
          Flopsy.logger.info("something blew up: #{exception.message}")
        end
      end
    end
    
    it "sets exceptions in handlers hash" do
      Flopsy::ExceptionHandler.handlers[:publish].size.should == 1
    end

    it "adds a #handle method to blocks that are passed in" do
      Flopsy::ExceptionHandler.handlers[:publish].first.should respond_to(:handle)
    end

    it "registers custom exception handler classes" do
      # given
      Flopsy::ExceptionHandler.reset
      class Flopsy::MyExceptionHandler
        def self.handle(exception)
          Flopsy.logger.info("something blew up: #{exception.message}")
        end
      end
      Flopsy::ExceptionHandler.define { |h| h.register(:publish, Flopsy::MyExceptionHandler) }
      
      # expect
      Flopsy::ExceptionHandler.handlers[:publish].first.should == Flopsy::MyExceptionHandler
    end
    
  end

  describe ".handle" do

    it "delegates to handlers registered for specific events" do
      # given
      Flopsy::ExceptionHandler.define do |h|
        h.register(:publish) { |exception, info| Flopsy.logger.info("oops!") }
      end

      # expect
      Flopsy.logger.should_receive(:info).with("oops!")

      # when
      Flopsy::ExceptionHandler.handle(:publish) { raise "oops!" }
    end
    
    it "delegates to handlers registered for 'all' as well as those registered for specific events" do
      # given
      Flopsy::ExceptionHandler.define do |h|
        h.register(:publish) { |exception, info| Flopsy.logger.info("oops!") }
        h.register(:all) { |exception, info| Flopsy.logger.info("oops!") }
      end

      # expect
      Flopsy.logger.should_receive(:info).twice.with("oops!")

      # when
      Flopsy::ExceptionHandler.handle(:publish) { raise "oops!" }
    end

    it "passes arguments to handlers" do
      # given
      Flopsy::ExceptionHandler.define do |h|
        h.register(:publish) { |exception, info| Flopsy.logger.info("error #{exception.message} raised in #{info[:action]}") }
      end

      # expect
      Flopsy.logger.should_receive(:info).with("error oops! raised in publishing")

      # when
      Flopsy::ExceptionHandler.handle(:publish, {:action => "publishing"}) { raise "oops!" }
    end
    
    it "raises exception if no handlers have been registered" do
      lambda {Flopsy::ExceptionHandler.handle(:publish) { raise "oops!" }}.should raise_error
    end
    
  end
  
end
