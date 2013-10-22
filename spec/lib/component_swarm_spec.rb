require 'spec_helper'

describe ComponentSwarm do
  module Sprockets
    class DirectiveProcessor
    end
  end

  let(:path) { "spec/fixtures/component_swarm.yml" }
  let(:sprockets_context) { OpenStruct.new(paths: [], pathname: "manifest") }

  describe "::load_configurations" do
    it "should load the yaml by path" do
      ComponentSwarm.load_configurations path
      ComponentSwarm.class_variable_get(:@@settings).should eql YAML.load_file(path)
    end
  end

  describe "::option" do
    before { ComponentSwarm.load_configurations(path) }

    it "should read the options from @@settings using string" do
      settings = ComponentSwarm.class_variable_get(:@@settings)
      ComponentSwarm.option(:components_load_path).should eql settings["components_load_path"]
    end
  end

  describe "::boot" do
    before { ComponentSwarm.load_configurations(path) }

    it "should add 'components_load_path' to sprockets load path" do
      sprockets_context.paths.should be_empty
      ComponentSwarm.boot sprockets_context
      ComponentSwarm.option(:components_load_path).each do |path|
        sprockets_context.paths.should include path
      end
    end

    it "should include ComponentSwarm::Directives into Sprockets::DirectiveProcessor" do
      methods = ComponentSwarm::Directives.methods - Object.methods
      ComponentSwarm.boot sprockets_context

      methods.each do |method|
        Sprockets::DirectiveProcessor.should respond_to(method)
      end
    end
  end

  describe "::manifest" do
    before do
      ComponentSwarm.load_configurations(path)
      ComponentSwarm.boot sprockets_context
      ComponentSwarm.class_variable_get(:@@repository).should eql({})
    end

    let(:manifest) { ComponentSwarm.manifest(sprockets_context) }
    
    it "should create and assign a new ComponentSwarm::Manifest to @@repository" do
      manifest.should be_an_instance_of ComponentSwarm::Manifest
      ComponentSwarm.class_variable_get(:@@repository)[sprockets_context.pathname].should eql manifest
    end

    it "should create ComponentSwarm::Manifest only once" do
      manifest.should be_an_instance_of ComponentSwarm::Manifest
      5.times { ComponentSwarm.manifest(sprockets_context) }
      manifest.should eql ComponentSwarm.manifest(sprockets_context)
    end
  end

  describe "::import_manifest" do
    before do
      ComponentSwarm.load_configurations(path)
      ComponentSwarm.boot sprockets_context
      manifest
    end

    let(:manifest) { ComponentSwarm.manifest(sprockets_context) }

    it "should call 'import!' on manifest defined in sprockets_context" do
      manifest.should_receive(:import!)
      ComponentSwarm.import_manifest sprockets_context
    end
  end
end
