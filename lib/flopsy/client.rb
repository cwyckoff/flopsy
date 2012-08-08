module Flopsy

  class Client

    class << self
      attr_reader :cached

      def get(opts = {})
        if @cached && @cached.connected?
          @cached
        else
          reset
          @cached = new_client(opts)
        end
      end

      def reset
        @cached = nil
      end

      def new_client(opts={})
        client = Bunny.new(Environment.options.merge(opts))
        client.start
        client
      end
    end

  end
end
