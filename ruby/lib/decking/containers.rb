require 'decking/container/create'
require 'decking/container/start'
require 'decking/container/delete'

module Decking
  class Container
    class << self
      include Enumerable

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
      begin
        config[method]
      rescue
        super method, *args, &block
      end
    end
  end
end

# TODO: Delete below; just screwing around with the container setup during prototyping
if __FILE__==$0 
  require 'decking'
  Decking::Parser.config_file '/Users/randy/git/decking/ruby/spec/resources/decking.yaml'
  Decking::Parser.parse 'container-tests'
  Decking::Parser.config.containers.map { |name, config| Decking::Container.add config }
  container_name="ubuntu.container-tests"
  #Decking::Container.map { |name, inst| puts name + ': ' + inst.config.image + ', ' + inst.config.name}
  #ap Decking::Container.count #=> 5
  #ap Decking::Container.all? { |name, inst| inst.config.data == true } #=> true if any of the containers have the data=true
  #ap Decking::Container.group_by{ |name, inst| inst.config.data } #=> Container instances grouped by whether or not data is true or false
  #ap Decking::Container.find_all{ |name, inst| inst.config.data == true } #=> Container instances that have data=true
  #ap Decking::Container[container_name].config.image #=> webapp
  #ap Decking::Container[container_name].volumes_from.inspect #=> ["repo", "config"]
  #ap Decking::Container[container_name].image.inspect #=> webapp
  #ap Decking::Container[container_name].domainname.inspect #=> qa.randywallace.com
  #puts Docker.url
  Decking::Container[container_name].delete!
  Decking::Container[container_name].create
  Decking::Container[container_name].start
  puts Docker::Container.get(container_name).logs 'stdout'=>true, 'stderr'=>true
end
