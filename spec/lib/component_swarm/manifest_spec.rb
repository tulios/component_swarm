require "spec_helper"

describe ComponentSwarm::Manifest do

  let(:sprockets_context) { OpenStruct.new(paths: [], pathname: "manifest") }  
  let(:manifest) { ComponentSwarm::Manifest.new(sprockets_context) }

  let(:directory) { "spec/fixtures/components" }
  let(:manifests) do
    [
      JSON.parse(File.read("#{directory}/example_1/manifest.json")),
      JSON.parse(File.read("#{directory}/example_2/manifest.json")),
      JSON.parse(File.read("#{directory}/example_3/manifest.json")),
      JSON.parse(File.read("#{directory}/example_4/manifest.json"))
    ]
  end

  describe "#use" do
    let(:component_path) { "#{directory}/example_1" }
    let(:manifest_path) { "#{component_path}/manifest.json" } 

    before do
      sprockets_context.should_receive(:resolve).with(manifest_path).and_return(manifest_path)
    end

    it "should register the component with its configuration" do
      manifest.use component_path
      manifest.components.keys.should include component_path
      manifest.components[component_path].should eql manifests[0]
    end
  end

  describe "#import!" do
    before do
      ["example_1", "example_2", "example_3", "example_4"].each_with_index do |example, index|
        path = "#{example}/manifest.json"
        sprockets_context.stub(:resolve).with(path).and_return("#{directory}/#{path}")
      end

      manifest.use "example_1"
    end

    describe "when dealing with 'text/css'" do
      before { sprockets_context.stub(:content_type).and_return("text/css") }

      it "should import the dependencies in the correct order" do
        sprockets_context.should_receive(:require_asset).with("example_2/css/style") do # dependency of example 1
          sprockets_context.should_receive(:require_asset).with("example_4/css/style") do # dependency of example 3
            sprockets_context.should_receive(:require_asset).with("example_3/css/style") do # dependency of example 1
              sprockets_context.should_receive(:require_asset).with("example_1/css/style") # component asset            
            end
          end
        end

        manifest.import!
      end

    end
  end
end
