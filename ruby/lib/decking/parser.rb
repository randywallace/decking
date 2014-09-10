require 'hashie'
require 'yaml'
require 'awesome_print'

module Decking
  class Parser

    attr_accessor :config, :cluster

    def initialize options = {}
      options[:decking_file] ||= 'decking.yaml'

      @config = Hashie::Mash.new(YAML.load_file(options[:decking_file]))

      confirm_requirements

    end

    def confirm_requirements
      raise "No Containers Defined" unless config.containers?
      raise "No Clusters Defined"   unless config.clusters?
    end

    def parse
      parse_images
      parse_containers
      parse_clusters
      parse_groups
    end

    def parse_images
      config.images.each do |key, val|
        config.images[key] = key unless @config.images[key]
      end
    end

    def parse_containers
      config.containers.each do |key, val|
        config.containers[key]                     ||= Hashie::Mash.new
        config.containers[key].dependencies        ||= Array.new
        config.containers[key]["mount-from"]       ||= Array.new
        config.containers[key].image               ||= key
        config.containers[key].aliases             ||= Array.new
        config.containers[key].dependencies.each_with_index do |v, idx|
          config.containers[key].dependencies[idx] = resolve_dependency v unless v.instance_of? Hash
        end
        config.containers[key]["mount-from"].each_with_index do |v, idx|
          raise "'mount-from' dependency '" + v + "' of container '" + key + "' does not exist" unless config.containers.key? v
        end
      end
    end

    def parse_clusters
      config.clusters.each do |key, val|
        if config.clusters[key].instance_of? Array
          cont_ar = config.clusters[key]
          config.clusters[key] = Hashie::Mash.new
          config.clusters[key].containers = cont_ar
        end
        if (config.clusters[key].key? 'group') && (!config.groups.key?(config.clusters[key].group))
          raise "Cluster '" + key + "' references invalid group '" + config.clusters[key].group
        end
        if (!config.clusters[key].key? 'group') && (config.groups.key? key)
          config.clusters[key].group = key
        end
      
        raise "Cluster '" + key + "' is empty" unless config.clusters[key].key? "containers"
        raise "Cluster '" + key + "' containers should be an Array" unless config.clusters[key].containers.instance_of? Array
      end
    end

    def parse_groups
      config.groups.each do |key, val|
        config.groups[key].options = Hashie::Mash.new unless config.groups[key].key? 'options'
        config.groups[key].containers = Hashie::Mash.new unless config.groups[key].key? 'containers'
        config.groups[key].containers.each do |c_key, c_val|
          if config.groups[key].containers[c_key].key? 'dependencies'
            config.groups[key].containers[c_key].dependencies.each_with_index do |v, idx|
              config.groups[key].containers[c_key].dependencies[idx] = resolve_dependency v
            end
          end
        end
      end
    end

    def merge_cluster_config cluster
      raise "Cluster '" + cluster + "' doesn't exist" unless config.clusters.key? cluster
      cluster = Hashie::Mash.new(config.clusters[cluster])
     # cluster = OpenStruct.new @config["clusters"][cluster]
     # ap cluster.marshal_dump

    end

    def print_parsed_config
      ap config
    end

    def resolve_dependency dep
      ret = Hash.new
      spl = dep.split ':'
      ret["dep"] = spl[0]
      unless spl[1].nil?
        ret["alias"] = spl[1]
      else
        ret["alias"] = spl[0]
      end
      ret
    end

  end
end
