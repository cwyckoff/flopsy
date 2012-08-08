module Flopsy

  class Client

    class << self
      attr_reader :cached

      def get(opts = {})
        @cached ||= (
                     client = Bunny.new(Environment.options.merge(opts))
                     client.start
                     client
                     )
      end

      def reset
        @cached = nil
      end
    end

  end
end
