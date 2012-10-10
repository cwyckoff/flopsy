$:.unshift File.expand_path(File.dirname(__FILE__))

require 'bunny'
require 'flopsy/logger'
require 'flopsy/filter'
require 'flopsy/environment'
require 'flopsy/exception_handler'
require 'flopsy/consumer'
require 'flopsy/client'

module Flopsy
  VERSION = '0.0.6'
  
  def self.version
    VERSION
  end
  
  def self.client(opts={})
    Client.get(opts)
  end

  def self.delete_queue(name, opts={})
    Client.get(opts).queue(name).delete
  end
  
  def self.exchange(name, opts={})
    Client.get(opts).exchange(name, opts)
  end
  
  def self.fanout_queue(exchange_name, queue_name, opts={})
    exch = Flopsy.exchange(exchange_name, :type => "fanout")
    queue = Flopsy.queue(queue_name, opts)
    queue.bind(exch)
    queue
  end
  
  def self.queue(name, opts={})
    Client.get(opts).queue(name, opts)
  end

  def self.publish(name, msg, opts={})
    if opts[:type] && opts[:type] == "fanout"
      exch = exchange(name, opts)
      exch.publish(Filter.filter(:publish, msg))
    else
      direct_exchange = exchange('')
      direct_exchange.publish(Filter.filter(:publish, msg), opts.merge(:key => name))
    end
  end
end
