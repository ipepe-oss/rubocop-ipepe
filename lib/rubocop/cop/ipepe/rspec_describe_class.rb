# frozen_string_literal: true

module RuboCop
  module Cop
    module Ipepe
      # Checks that RSpec top-level describe blocks specify a class constant.
      # This helps with tools like rspec-big-infer that rely on explicit class references.
      #
      # @example
      #   # bad
      #   describe "MyClass" do
      #   end
      #
      #   # good
      #   describe MyClass do
      #   end
      class RspecDescribeClass < ::RuboCop::Cop::Base
        MSG = "RSpec top-level `describe` should specify a class constant, not a string. " \
              "This helps with rspec-big-infer."

        def on_block(node)
          return unless rspec_describe?(node)
          return unless top_level_describe?(node)

          send_node = node.send_node
          first_arg = send_node.first_argument

          return unless first_arg
          return if constant_argument?(first_arg)

          add_offense(first_arg)
        end

        private

        def rspec_describe?(node)
          send_node = node.send_node
          send_node.method?(:describe)
        end

        def top_level_describe?(node)
          # Check if this describe is at the top level (not nested inside another describe/context)
          parent = node.parent
          while parent
            if parent.block_type?
              parent_send = parent.send_node
              return false if parent_send&.method?(:describe) || parent_send&.method?(:context)
            end
            parent = parent.parent
          end
          true
        end

        def constant_argument?(node)
          node.const_type?
        end
      end
    end
  end
end
