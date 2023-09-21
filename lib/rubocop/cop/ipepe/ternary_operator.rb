module RuboCop
  module Cop
    module Ipepe
      class TernaryOperator < ::RuboCop::Cop::Base
        extend AutoCorrector

        MSG = "Use `if` instead of ternary operator.".freeze

        def on_if(node)
          return unless node.ternary?

          add_offense(node) do |corrector|
            corrector.replace(
              node,
              [
                "if #{node.condition.source}",
                node.if_branch.source,
                "else",
                node.else_branch.source,
                "end"
              ].join("\n")
            )
          end
        end
      end
    end
  end
end
