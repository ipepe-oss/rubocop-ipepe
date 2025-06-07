module RuboCop
  module Cop
    module Ipepe
      class ServiceInstanceVariables < ::RuboCop::Cop::Base
        MSG = "Do not use instance variables outside #initialize and #call".freeze

        def on_ivar(node)
          check_node(node)
        end

        def on_ivasgn(node)
          check_node(node)
        end

        private

        def check_node(node)
          return unless app_service_file?

          method = node.each_ancestor(:def).first
          return if method && [:initialize, :call].include?(method.method_name)

          add_offense(node)
        end

        def app_service_file?
          processed_source.file_path.include?(File.join("app", "services"))
        end
      end
    end
  end
end
