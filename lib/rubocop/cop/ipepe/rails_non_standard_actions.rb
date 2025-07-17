module RuboCop
  module Cop
    module Ipepe
      class RailsNonStandardActions < ::RuboCop::Cop::Base
        MSG = "Non-standard Rails actions should be defined as sub-controllers".freeze

        STANDARD_ACTIONS = %i[index show new edit create update destroy].freeze

        def on_def(node)
          return unless in_controller_class?(node)

          method_name = node.method_name
          return if STANDARD_ACTIONS.include?(method_name)

          add_offense(node, message: format_message(method_name))
        end

        private

        def in_controller_class?(node)
          class_node = node.each_ancestor(:class).first
          return false unless class_node

          class_name = class_node.identifier.source
          class_name.end_with?("Controller")
        end

        def format_message(method_name)
          "Non-standard action '#{method_name}' should be moved to a sub-controller (e.g., #{suggested_controller_name(method_name)})"
        end

        def suggested_controller_name(method_name)
          "#{method_name.to_s.capitalize}Controller"
        end
      end
    end
  end
end