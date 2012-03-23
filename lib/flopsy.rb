$:.unshift File.expand_path(File.dirname(__FILE__))

require 'bunny'
require 'flopsy/logger'
require 'flopsy/filter'
require 'flopsy/environment'
require 'flopsy/exception_handler'
require 'flopsy/consumer'

module Flopsy
  VERSION = '0.0.3'
  
  def self.version
    VERSION
  end
  
  def self.new_bunny(opts = {})
    if Environment.mode == :test
      FakeClient.new
    elsif Environment.set?
      Bunny.new(Environment.options.merge(opts))
    else
      Bunny.new(opts)
    end
  end

  def self.client(opts={})
    Flopsy.new_bunny(opts)
  end

  def self.delete_queue(name, opts={})
    run { |b| b.queue(name).delete }
  end
  
  def self.exchange(name, opts={})
    bunny = Flopsy.new_bunny
    bunny.start
    bunny.exchange(name, opts)
  end
  
  def self.fanout_queue(exchange_name, queue_name)
    exch = Flopsy.exchange(exchange_name, :type => "fanout")
    queue = Flopsy.queue(queue_name)
    queue.bind(exch)
    queue
  end
  
  def self.queue(name, opts={})
    bunny = Flopsy.new_bunny
    bunny.start
    bunny.queue(name, opts)
  end

  def self.publish(name, msg, opts={})
    run do |bunny|
      if opts[:type] && opts[:type] == "fanout"
        exch = bunny.exchange(name, opts.merge(:type => "fanout"))
        exch.publish(Filter.filter(:publish, msg))
      else
        filtered = Filter.filter(:publish, msg)
        direct_exchange = bunny.exchange('')
        direct_exchange.publish(filtered, opts.merge(:key => name))
      end
    end
  end
  
  # Runs a code block using a short-lived connection
  def self.run(opts = {}, &block)
    raise ArgumentError, 'Bunny#run requires a block' unless block
    bunny = Flopsy.new_bunny(opts)
    
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
