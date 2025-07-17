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
        # Not including RuboCop::Cop::Mixin::ConfigurablePaths due to loading issues.
        # The required path configuration logic is implemented directly in target_file?
        extend AutoCorrector

        MSG = 'Instance variables should only be used inside initialize and call methods in services.' # Reverted

        def on_ivar(node)
          # processed_source is available on the cop instance (self.processed_source)
          file_path_string = processed_source&.file_path
          return unless file_path_string && relevant_file?(file_path_string)
          return if whitelisted_method?(node)

          add_offense(node)
        end

        def on_ivasgn(node)
          # processed_source is available on the cop instance (self.processed_source)
          file_path_string = processed_source&.file_path

          # DEBUG code removed
          # if file_path_string&.include?('app/jobs/my_job.rb') && node.children.first == :@ivar
          #   puts "DEBUG my_job.rb @ivar: node.source = #{node.source.inspect}"
          #   puts "DEBUG my_job.rb @ivar: node.loc.expression.begin_pos = #{node.loc.expression.begin_pos}"
          #   puts "DEBUG my_job.rb @ivar: node.loc.expression.end_pos = #{node.loc.expression.end_pos}"
          #   puts "DEBUG my_job.rb @ivar: node.loc.expression.source_line = #{node.loc.expression.source_line.inspect}"
          #   puts "DEBUG my_job.rb @ivar: node.loc.expression.column = #{node.loc.expression.column}"
          #   puts "DEBUG my_job.rb @ivar: node.loc.expression.last_column = #{node.loc.expression.last_column}"
          # end

          return unless file_path_string && relevant_file?(file_path_string)
          return if whitelisted_method?(node)

          add_offense(node)
        end

        private

        def target_file?(file_path_string)
          # This method assumes file_path_string is a non-nil string.
          current_cop_config = cop_config
          included_paths = current_cop_config.fetch('IncludedPaths', ['app/services/**/*.rb'])
          excluded_paths = current_cop_config.fetch('ExcludedPaths', [])

          # Debugging code removed.

          matches_included = included_paths.any? do |pattern|
            RuboCop::PathUtil.match_path?(pattern, file_path_string)
          end

          return false unless matches_included

          return true if excluded_paths.empty?

          matches_excluded = excluded_paths.any? do |pattern|
            RuboCop::PathUtil.match_path?(pattern, file_path_string)
          end

          !matches_excluded
        end

        # This method is called by RuboCop's core `excluded_file?` logic with a file path string.
        # It's also called by on_ivar/on_ivasgn with a file path string.
        def relevant_file?(file_path_string)
          # Ensure target_file? is only called with a string, and handle potential nil early.
          file_path_string && target_file?(file_path_string)
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
