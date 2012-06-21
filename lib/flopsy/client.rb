module Flopsy
  class Client
    
    class << self
      attr_reader :cache

      def get(opts = {})
        @cache ||= (
          client = Bunny.new(Environment.options.merge(opts))
          client.start
          client
        )
      end

      def reset
        @cache = nil
      end
    end
  
  end
end
