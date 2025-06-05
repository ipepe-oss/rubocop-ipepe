module RuboCop
  module Cop
    module Ipepe
      class RspecChangeFromToNotBy < ::RuboCop::Cop::Base
        MSG = "Prefer `change { }.from().to()` over `change { }.by()`".freeze

        def on_send(node)
          return unless change_by?(node)

          add_offense(node)
        end

        private

        def change_by?(node)
          return false unless node.method?(:by)

          receiver = node.receiver
          receiver = receiver.send_node if receiver&.block_type?
          receiver&.send_type? && receiver&.method?(:change)
        end
      end
    end
  end
end
