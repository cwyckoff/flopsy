$:.unshift File.expand_path(File.dirname(__FILE__))

require 'flopsy/logger'
require 'flopsy/filter'
require 'flopsy/environment'
require 'flopsy/exception_handler'
require 'flopsy/consumer'

module Flopsy
  
  VERSION = '0.0.1'
  
  # Returns the Flopsy version number
  def self.version
    VERSION
  end
  
  # Instantiates new Bunny::Client
  def self.new_bunny(opts = {})
    # Return client
    if Environment.mode == :test
      FakeClient.new
    elsif Environment.set?
      Bunny.new(Environment.options.merge(opts))
    else
      Bunny.new(opts)
    end
  end

  def self.client(opts={})
    Bunny.new(opts)
  end

  def self.delete_queue(name, opts={})
    run { |b| b.queue(name).delete }
  end
  
  def self.exchange(name, opts={})
    bunny = Bunny.new
    bunny.start
    bunny.exchange(name, opts)
  end
  
  def self.fanout_queue(exchange_name, queue_name)
    exch = Bunny.exchange(exchange_name, :type => "fanout")
    queue = Bunny.queue(queue_name)
    queue.bind(exch)
    queue
  end
  
  def self.queue(name, opts={})
    bunny = Bunny.new
    bunny.start
    bunny.queue(name, opts)
  end

  def self.publish(name, msg, opts={})
    run do |bunny|
      if opts[:type] && opts[:type] == "fanout"
        exch = bunny.exchange(name, opts.merge(:type => "fanout"))
        exch.publish(Filter.filter(:consume, msg))
      else
        queue = bunny.queue(name, opts.merge(:type => "direct"))
        queue.publish(Filter.filter(:consume, msg))
      end
    end
  end
  
  # Runs a code block using a short-lived connection
  def self.run(opts = {}, &block)
    raise ArgumentError, 'Bunny#run requires a block' unless block
    bunny = Bunny.new(opts)
    
    begin
      bunny.start
      block.call(bunny)
    ensure
      bunny.stop
    end

    # Return success
    :run_ok
  end

end
