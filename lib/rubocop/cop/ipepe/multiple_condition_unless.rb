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
            corrector.replace(node, "if !(#{node.condition.source})\n#{node.if_branch.source}\nend")
          end
        end
      end
    end
  end
end
