module RuboCop
  module Cop
    module Ipepe
      class MultipleConditionUnless < ::RuboCop::Cop::Base
        extend AutoCorrector
        MSG = "Use only one condition in unless or change to if".freeze

        def on_if(node)
          return unless node.unless?
          return unless node.condition.and_type?

          add_offense(node) do |corrector|
            # change `unless` to `if !(condition)`
            replacement_lines = [
              "if !(#{node.condition.source})",
              node.if_branch.source
            ]
            if node.else_branch
              replacement_lines << "else"
              replacement_lines << node.else_branch.source
            end
            replacement_lines << "end"
            corrector.replace(node, replacement_lines.join("\n"))
          end
        end
      end
    end
  end
end
