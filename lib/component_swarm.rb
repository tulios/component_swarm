require 'yaml'
require 'json'

module ComponentSwarm

  def self.boot sprockets_context
    option("components_load_path").each do |path|
      sprockets_context.paths << path
    end

    @@repository = {}
    Sprockets::DirectiveProcessor.send :include, Directives
  end

  def self.load_configurations path
    @@settings = YAML.load_file path
  end

  def self.option name
    @@settings[name.to_s]
  end

  def self.manifest name
    @@repository[name] ||= Manifest.new(name)
  end

  def self.import_manifest sprockets_context
    name = sprockets_context.pathname.to_s
    @@repository[name].import!(sprockets_context)
  end

end

require 'component_swarm/version'
require 'component_swarm/manifest'
require 'component_swarm/directives'
require 'component_swarm/railtie' if defined? Rails
