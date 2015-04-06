module Decking
  module Parser
    # Singleton Method: https://practicingruby.com/articles/ruby-and-the-singleton-pattern-dont-get-along
    extend self

    attr_accessor :config

    def config_file config_file
      config_file ||= 'decking.yaml'

      @config = Hashie::Mash.new(YAML.load_file(config_file))

      confirm_requirements

    end

    def print
      puts config.to_yaml
    end

    def parse cluster
      parse_images
      parse_containers
      parse_clusters
      parse_groups
      merge_cluster_config cluster
    end

    private

    def confirm_requirements
      raise "No Containers Defined" unless config.containers?
      raise "No Clusters Defined"   unless config.clusters?
      raise "No Images Defined"     unless config.images?
    end


    def parse_images
      config.images.each do |key, val|
        config.images[key] = key unless @config.images[key]
      end
    end

    def parse_containers
      config.containers.each do |key, val|
        config.containers[key]               ||= Hashie::Mash.new
        config.containers[key].links         ||= Array.new
        config.containers[key].binds         ||= Array.new
        config.containers[key].lxc_conf      ||= Array.new
        config.containers[key].domainname    ||= ""
        config.containers[key].command       ||= ""
        config.containers[key].entrypoint    ||= nil
        config.containers[key].memory        ||= 0
        config.containers[key].memory_swap   ||= 0
        config.containers[key].cpu_shares    ||= 0
        config.containers[key].cpu_set       ||= ""
        config.containers[key].attach_stdout ||= false
        config.containers[key].attach_stderr ||= false
        config.containers[key].attach_stdin  ||= false
        config.containers[key].tty           ||= false
        config.containers[key].open_stdin    ||= false
        config.containers[key].stdin_once    ||= false
        config.containers[key].volumes_from  ||= Array.new
        config.containers[key].image         ||= key
        config.containers[key].port          ||= Array.new
        config.containers[key].aliases       ||= Array.new
        config.containers[key].data          ||= false
        config.containers[key].hostname      ||= key
        config.containers[key].links.each_with_index do |v, idx|
          config.containers[key].links[idx] = resolve_dependency v unless v.instance_of? Hash
        end
        config.containers[key].volumes_from.each_with_index do |v, idx|
          unless config.containers.key? v
          raise "'volumes_from' dependency '" + v + "' of container '" + key + "' does not exist" 
          end
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
        config.groups[key]            = Hashie::Mash.new if config.groups[key].nil?
        config.groups[key].options    = Hashie::Mash.new unless config.groups[key].key? 'options'
        config.groups[key].containers = Hashie::Mash.new unless config.groups[key].key? 'containers'
        config.groups[key].containers.each do |c_key, c_val|
          if config.groups[key].containers[c_key].key? 'links'
            config.groups[key].containers[c_key].links.each_with_index do |v, idx|
              config.groups[key].containers[c_key].links[idx] = resolve_dependency v
            end
          end
        end
      end
    end

    def merge_cluster_config cluster
      raise "Cluster '" + cluster + "' doesn't exist" unless config.clusters.key? cluster
      c = Hashie::Mash.new
      c.containers = Hash.new
      
      # Merge primary container configs
      config.clusters[cluster].containers.each_with_index do |key, idx|
        c.containers[key] = config.containers[key]
      end

      c.containers.each do |k, v|
        # Merge Global Overrides
        c.containers[k] = c.containers[k].deep_merge(config.global) if config.key? 'global'
        # Merge Group Overrides
        c.containers[k] = c.containers[k].deep_merge(config.groups[config.clusters[cluster].group].options)
        # Merge Group Container Overrides
        if config.groups[config.clusters[cluster].group].containers.key? k
          c.containers[k] = c.containers[k].deep_merge(config.groups[config.clusters[cluster].group].containers[k])
        end
        c.containers[k].name = k + '.' + cluster
        c.containers[k].domainname = cluster + '.' + config.global.domainname if config.key?('global') && config.global.key?('domainname')
      end
      images = self.config.images
      group  = self.config.clusters[cluster].group
      self.config = c
      self.config.images = images
      self.config.cluster = cluster
      self.config.group = group
      self.config
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
