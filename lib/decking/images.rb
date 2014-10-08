require 'decking/helpers'

module Decking
  class Image
    include Decking::Helpers
    class << self
      include Decking::Helpers
      include Enumerable

      #def delete_all ; map{|n, c| c.delete  }; end
      #def delete_all!; map{|n, c| c.delete! }; end

      def images
        @images ||= Hash.new
      end

      def instances
        @instances ||= Hash.new
      end

      def add params
        images.update params.name => params
        self[params.name]
      end

      def [](name)
        instances[name] ||= new(name, @images[name])
      end

      def each &block
        @instances.each(&block)
      end
    end

    attr_reader :name, :config

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
