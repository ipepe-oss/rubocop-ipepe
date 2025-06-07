# frozen_string_literal: true

module RuboCop
  module Cop
    module Ipepe
      # This cop checks for instance variable usage outside initialize and call methods
      # in services.
      #
      # @example
      #
      #   # bad
      #   class SomeService
      #     def initialize
      #       @foo = 1
      #     end
      #
      #     def other_method
      #       puts @foo # bad
      #     end
      #
      #     def call
      #       @bar = 2 # good
      #       puts @bar # good
      #     end
      #   end
      #
      #   # good
      #   class SomeService
      #     def initialize
      #       @foo = 1
      #     end
      #
      #     def call
      #       puts @foo # good
      #     end
      #   end
      #
      class InstanceVariableUsage < Base
        MSG = 'Instance variables should only be used inside initialize and call methods in services.'

        def on_ivar(node)
          return unless relevant_file?(node)
          return if whitelisted_method?(node)

          add_offense(node)
        end

        def on_ivasgn(node)
          return unless relevant_file?(node)
          return if whitelisted_method?(node)

          add_offense(node)
        end

        private

        def relevant_file?(_node)
          # RuboCop::Cop::Base provides `processed_source` which has the file path
          return false unless processed_source&.file_path
          processed_source.file_path.match?(%r{app/services/.*\.rb$})
        end

        def whitelisted_method?(node)
          node.each_ancestor(:def, :defs).any? do |ancestor|
            method_name = ancestor.method_name
            method_name == :initialize || method_name == :call
          end
        end
      end
    end
  end
end
