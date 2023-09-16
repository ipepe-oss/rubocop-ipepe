module RuboCop
  module Cop
    module Ipepe
      # TODO: Write cop description and example of bad / good code. For every
      # `SupportedStyle` and unique configuration, there needs to be examples.
      # Examples must have valid Ruby syntax. Do not use upticks.
      #
      # @safety
      #   Delete this section if the cop is not unsafe (`Safe: false` or
      #   `SafeAutoCorrect: false`), or use it to explain how the cop is
      #   unsafe.
      #
      # @example EnforcedStyle: bar (default)
      #   # Description of the `bar` style.
      #
      #   # bad
      #   bad_bar_method
      #
      #   # bad
      #   bad_bar_method(args)
      #
      #   # good
      #   good_bar_method
      #
      #   # good
      #   good_bar_method(args)
      #
      # @example EnforcedStyle: foo
      #   # Description of the `foo` style.
      #
      #   # bad
      #   bad_foo_method
      #
      #   # bad
      #   bad_foo_method(args)
      #
      #   # good
      #   good_foo_method
      #
      #   # good
      #   good_foo_method(args)
      #
      class TernaryOperator < ::RuboCop::Cop::Base
        extend AutoCorrector

        MSG = "Use `if` instead of ternary operator.".freeze

        def on_if(node)
          return unless node.ternary?

          add_offense(node) do |corrector|
            corrector.replace(node, "if #{node.condition.source}\n#{node.if_branch.source}\nend")
          end
        end

        private

        def ternary_operator?(node)
          node.if_type? && node.else? && node.ternary?
        end
      end
    end
  end
end
