module RuboCop
  module Cop
    module Ipepe
      class ServiceInstanceVariables < ::RuboCop::Cop::Base
        MSG = "Do not use instance variables outside #initialize and #call".freeze
        DEFAULT_PATHS = ["app/services/**/*.rb"].freeze

        def on_ivar(node)
          check_node(node)
        end

        def on_ivasgn(node)
          check_node(node)
        end

        private

        def check_node(node)
          return unless included_file?

          method = node.each_ancestor(:def).first
          return if method && [:initialize, :call].include?(method.method_name)

          add_offense(node)
        end

        def included_file?
          Array(cop_config["Include"] || DEFAULT_PATHS).any? do |pattern|
            File.fnmatch?(pattern, processed_source.file_path,
                          File::FNM_PATHNAME | File::FNM_EXTGLOB)
          end
        end
      end
    end
  end
end
