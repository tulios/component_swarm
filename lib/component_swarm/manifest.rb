module ComponentSwarm
  class Manifest

    def initialize manifest_path
      @path = manifest_path
      @components = {}
      @components_dependencies = {}      
    end

    def use component_name, config
      @components[component_name] = config
    end

    def import! context
      @sprockets = context

      case @sprockets.content_type
      when /css/
        dependencies = get_dependencies
        dependencies.each do |component_name|
          import_dependency "css", component_name
        end

        @components.each_pair do |name, config|
          import_type("css", name, config) unless dependencies.include?(name)
        end

      when /javascript/
        get_libs.each do |lib_name|
          @sprockets.require_asset lib_name
        end

      dependencies = get_dependencies
        dependencies.each do |component_name|
          import_dependency "js", component_name
        end

        @components.each_pair do |name, config|
          import_type("js", name, config) unless dependencies.include?(name)
        end
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

    def get_dependencies
      array = []
      @components.values.each do |config|
        array << config["dependencies"] if config["dependencies"]
      end

      array.flatten.uniq
    end

    def import_type type, component_name, component_config
      (component_config[type] || []).each do |file|
        @sprockets.require_asset "#{component_name}/#{type}/#{file}"
      end
    end

    def import_dependency type, component_name
      config = load_dependency component_name
      dependencies = config["dependencies"] || []
      dependencies.each {|name| import_dependency(type, name)}
      import_type type, component_name, config
    end

    def load_dependency component_name
      config = @components_dependencies[component_name]
      return config if config

      manifest_path = @sprockets.resolve "#{component_name}/manifest.json"
      config = JSON.parse File.read(manifest_path.to_s)
      @components_dependencies[component_name] = config
      config
    end

  end
end
