module Flopsy
  class Consumer
    # expects two arguments:
    # 1) a queue name to consume from
    # 2) an instantiated message-handler object
    # 3) a hash of options (e.g., :type => "fanout", :ack => true, :exch_name => "foo")
    def self.start(queue_name, message_handler, opts={})
      ExceptionHandler.handle(:consume, {:action => :consuming, :destination => queue_name, :options => opts}) do
        if opts[:type] == "fanout"
          queue = Flopsy.fanout_queue(opts[:exch_name], queue_name)
        else
          queue = Flopsy.queue(queue_name.to_sym)
        end

        Flopsy.logger.info(" == FLOPSY :: Listening on #{queue.name}...")
        queue.subscribe(opts) do |msg|
          filtered = Filter.filter(:consume, msg[:payload])
          message_handler.process(filtered)
        end
      end
    end
  end
end
