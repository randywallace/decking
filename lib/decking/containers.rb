require 'decking/helpers'
require 'decking/container/create'
require 'decking/container/start'
require 'decking/container/delete'
require 'decking/container/stop'
require 'decking/container/attach'

module Decking
  class Container
    include Decking::Helpers
    class << self
      include Decking::Helpers
      include Enumerable

      def delete_all ; map{|n, c| c.delete  }; end
      def delete_all!; map{|n, c| c.delete! }; end

      def create_all ; map{|n, c| c.create  }; end
      def create_all!; map{|n, c| c.create! }; end

      def start_all  ; map{|n, c| c.start   }; end

      def stop_all   ; map{|n, c| c.stop    }; end
      def stop_all!  ; map{|n, c| c.stop!   }; end

      def attach_all 
        run_with_threads_multiplexed :attach, instances
      end

      def tail_all_logs
        run_with_threads_multiplexed :tail_logs, instances
      end

      def containers
        @containers ||= Hash.new
      end

      def instances
        @instances ||= Hash.new
      end

      def add params
        containers.update params.name => params
        self[params.name]
      end

      def [](name)
        instances[name] ||= new(name, @containers[name])
      end

      def each &block
        @instances.each(&block)
      end
    end

    attr_reader :name, :config, :container

    def initialize name, params
      @name   = name
      @config = params
    end

    def method_missing method, *args, &block
      if config.key? method
        config[method]
      else
        super
      end
    end
  end
end
