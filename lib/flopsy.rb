$:.unshift File.expand_path(File.dirname(__FILE__))

require 'bunny'
require 'flopsy/logger'
require 'flopsy/filter'
require 'flopsy/environment'
require 'flopsy/exception_handler'
require 'flopsy/consumer'
require 'flopsy/client'

module Flopsy
  VERSION = '0.0.1'
  
  def self.version
    VERSION
  end
  
  def self.client(opts={})
    Client.get(opts)
  end

  def self.delete_queue(name, opts={})
    run { |b| b.queue(name).delete }
  end
  
  def self.exchange(name, opts={})
    Client.get(opts).exchange(name, opts)
  end
  
  def self.fanout_queue(exchange_name, queue_name)
    exch = Flopsy.exchange(exchange_name, :type => "fanout")
    queue = Flopsy.queue(queue_name)
    queue.bind(exch)
    queue
  end
  
  def self.queue(name, opts={})
    Client.get(opts).queue(name, opts)
  end

  def self.publish(name, msg, opts={})
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
