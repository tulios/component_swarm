module ComponentSwarm
  module Directives

    def process_use_directive component_path
      manifest_path = context.resolve "#{component_path}/manifest.json"
      json = JSON.parse File.read(manifest_path.to_s)
      ComponentSwarm.manifest(context.pathname.to_s).use(component_path, json)
    end

    def process_swarm_import_directive
      ComponentSwarm.import_manifest context
    end

  end
end
