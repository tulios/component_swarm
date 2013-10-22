module ComponentSwarm
  class Manifest

    attr_reader :components

    def initialize sprockets_context
      @path = sprockets_context.pathname.to_s
      @sprockets_context = sprockets_context
      @components = {}
      @dependencies = {}
      @required_components = {"css" => [], "js" => []}
    end

    def use component_path
      manifest_path = @sprockets_context.resolve "#{component_path}/manifest.json"
      config = JSON.parse File.read(manifest_path.to_s)
      @components[component_path] = config
    end

    def import!
      dependencies = collect_dependencies
      case @sprockets_context.content_type
      when /css/
        dependencies.each {|component_path| import_dependency "css", component_path}
        @components.each_pair {|name, config| import_type("css", name, config) unless dependencies.include?(name)}

      when /javascript/
        get_libs.each {|lib_name| @sprockets_context.require_asset lib_name}
        dependencies.each {|component_name| import_dependency "js", component_name}
        @components.each_pair {|name, config| import_type("js", name, config) unless dependencies.include?(name)}
      end
    end

    private
    def get_libs
      array = []
      @components.values.each do |config|
        array << config["libs"] if config["libs"]
      end

      array.flatten.uniq
    end

    def collect_dependencies
      array = []
      @components.values.each do |config|
        array << config["dependencies"] if config["dependencies"]
      end

      array.flatten.uniq
    end

    def import_type type, component_path, component_config
      return if @required_components[type].include?(component_path)
      @required_components[type] << component_path

      (component_config[type] || []).each do |file|
        @sprockets_context.require_asset "#{component_path}/#{type}/#{file}"
      end
    end

    def import_dependency type, component_path
      config = load_dependency component_path
      dependencies = config["dependencies"] || []
      dependencies.each {|name| import_dependency(type, name)}
      import_type type, component_path, config
    end

    def load_dependency component_path
      config = @dependencies[component_path]
      return config if config

      manifest_path = @sprockets_context.resolve "#{component_path}/manifest.json"
      config = JSON.parse File.read(manifest_path.to_s)
      @dependencies[component_path] = config
    end

  end
end
