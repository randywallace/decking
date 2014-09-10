require 'awesome_print'
require_relative 'spec_helper'

describe Decking::Parser do
  let(:inst) { Decking::Parser.new :decking_file => 'spec/resources/decking.yaml' }

  describe '.parse_images()' do

    it 'sets value to key when blank' do
      inst.parse_images
      expect(inst.config.images.blank).to eq("blank")
    end
  end

  describe '.parse_containers()' do

    it 'sets image to container name when missing' do
      inst.parse_containers
      expect(inst.config.containers.blank_container_image.image).to eq("blank_container_image")
    end

    it 'resolves dependencies into container and alias' do
      inst.parse_containers
      expect(inst.config.containers.repos.dependencies[0]).to eq({"dep" => "elasticsearch", "alias" => "es"})
      expect(inst.config.containers.repos.dependencies[1]).to eq({"dep" => "config", "alias" => "config"})
    end

    it 'ensures that mount-from dependencies exist' do
      inst.config.containers.repos["mount-from"] = ["not-exists"]
      expect{inst.parse_containers}.to raise_error(RuntimeError)
    end
  end

  describe '.parse_clusters()' do

    it 'mangles a shorthand container array' do
      inst.parse_clusters
      expect(inst.config.clusters.qa.containers).to eq(["repos", "config", "webapp-main", "webapp-admin"])
    end

    it 'sets the group when group exists' do
      inst.parse_clusters
      expect(inst.config["clusters"]["qa"]["group"]).to eq("qa")
    end

    it 'raises an error when a cluster group does not exist' do
      inst.config.clusters.no_group = Hashie::Mash.new
      inst.config.clusters.no_group.group = "no_group"
      expect{inst.parse_clusters}.to raise_error(RuntimeError)
    end

  end

  describe '.parse_groups()' do
    it 'resolves dependencies into container and alias' do
      inst.parse_groups
      expect(inst.config.groups["qa-mod"].containers["webapp-admin"].dependencies[0]).to eq({"dep" => "elasticsearch", "alias" => "elasticsearch"})
    end
  end

  describe '.merge_cluster_config()' do
    it 'does not fail' do
      inst.parse
      inst.merge_cluster_config 'qa'
    end
  end

  describe '.print_parsed_config()' do 

    it 'prints the config' do
      inst.parse
    #  inst.merge_cluster_config "qa-mod"
      #inst.print_parsed_config
    end
  end
end

