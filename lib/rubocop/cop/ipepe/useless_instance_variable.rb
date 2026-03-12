require 'set'

module RuboCop
  module Cop
    module Ipepe
      class UselessInstanceVariable < ::RuboCop::Cop::Base
        MSG = "Use local variable instead of instance variable for better visibility and typo protection".freeze

        def on_ivasgn(node)
          # Get the instance variable name
          ivar_name = node.children.first
          
          # Find the method that contains this assignment
          method_node = find_enclosing_method(node)
          return unless method_node
          
          # Check if this instance variable could be a local variable
          if useless_instance_variable?(ivar_name, method_node)
            add_offense(node)
          end
        end

        private

        def find_enclosing_method(node)
          node.each_ancestor(:def, :defs).first
        end

        def useless_instance_variable?(ivar_name, method_node)
          # Get the class/module containing this method
          class_node = method_node.each_ancestor(:class, :module).first
          return false unless class_node

          # Find all usage of this instance variable in the class
          ivar_usages = []
          class_node.each_descendant(:ivar, :ivasgn) do |ivar_node|
            if ivar_node.children.first == ivar_name
              ivar_usages << ivar_node
            end
          end

          # Count how many methods use this instance variable
          methods_using_ivar = Set.new
          
          ivar_usages.each do |usage|
            containing_method = find_enclosing_method(usage)
            if containing_method
              methods_using_ivar << containing_method
            end
          end

          # Flag instance variables that are used in any methods (1 or more)
          # as they could be local variables passed between methods
          methods_using_ivar.size >= 1
        end
      end
    end
  end
end