module ComponentSwarm
  class Railtie < Rails::Railtie
    
    initializer "component_swarm.initializer" do |app|
      ComponentSwarm.load_configurations File.join(Rails.root, "config/component_swarm.yml")
      ComponentSwarm.boot app.config.assets
    end

  end
end
