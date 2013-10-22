module ComponentSwarm
  module Directives

    def process_use_directive component_path
      ComponentSwarm.manifest(context).use(component_path)
    end

    def process_swarm_import_directive
      ComponentSwarm.import_manifest context
    end

  end
end
