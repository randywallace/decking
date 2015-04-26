require_relative 'spec_helper'

describe Decking::Parser do
  before(:each) { Decking::Parser.config_file('spec/resources/decking.yaml') }

  describe '#parse' do

    it 'sets image value to key when blank' do
      Decking::Parser.parse 'qa'
      expect(Decking::Parser.config.images.blank.name).to eq("blank:latest")
      expect(Decking::Parser.config.images.base.name).to eq("fail")
      expect(Decking::Parser.config.images.repos.name).to eq("repos:v1.02")
      expect(Decking::Parser.config.images["eds-webapp"].name).to eq("eds-webapp:latest")
    end

    it 'sets image key in containers to container name when missing' do
      Decking::Parser.parse 'qa'
      expect(Decking::Parser.config.containers.blank_container_image.image).to eq("blank_container_image")
    end

    it 'resolves links into container and alias' do
      Decking::Parser.parse 'qa'
      expect(Decking::Parser.config.containers.repos.links[0]).to eq({"dep" => "elasticsearch", "alias" => "es"})
      expect(Decking::Parser.config.containers.repos.links[1]).to eq({"dep" => "config", "alias" => "config"})
    end

    it 'ensures that volumes_from links exist' do
      Decking::Parser.config.containers.repos.volumes_from = ["not-exists"]
      expect{Decking::Parser.parse 'qa'}.to raise_error(RuntimeError)
    end

    it 'raises an error when a cluster group does not exist' do
      Decking::Parser.config.clusters.no_group = Hashie::Mash.new
      Decking::Parser.config.clusters.no_group.group = "no_group"
      expect{Decking::Parser.parse 'qa'}.to raise_error(RuntimeError)
    end

    it 'resolves links into container and alias' do
      Decking::Parser.parse 'qa-mod'
      expect(Decking::Parser.config.containers["webapp-admin"].links[0]).to eq({"dep" => "elasticsearch", "alias" => "elasticsearch"})
    end

    it 'appropriately handles overrides' do
      Decking::Parser.parse 'qa'
      expect(Decking::Parser.config.containers.keys).to eq(['blank_container_image', 'repos', 'config', 'webapp-main', 'webapp-admin'])
      expect(Decking::Parser.config.containers['webapp-admin'].env.WEBAPP).to eq('admin')
      expect(Decking::Parser.config.containers['webapp-admin'].env.ENVIRONMENT).to eq('qa')
      expect(Decking::Parser.config.containers['webapp-admin'].env.TEST_VAR).to eq('test')
      expect(Decking::Parser.config.containers['webapp-admin'].env.GITHUB_REPO).to eq('test')
      expect(Decking::Parser.config.containers['webapp-admin'].env.AWS_ACCESS_KEY).to eq('key')
      expect(Decking::Parser.config.containers['webapp-admin'].env.AWS_SECRET_ACCESS_KEY).to eq('secret2')
      expect(Decking::Parser.config.containers['webapp-admin'].image).to eq('webapp')
      expect(Decking::Parser.config.containers['webapp-admin'].volumes_from).to eq(['repos','config'])
      expect(Decking::Parser.config.containers['webapp-admin'].port).to eq(['82:80'])
      expect(Decking::Parser.config.group).to eq('qa')
    end
  end

end

