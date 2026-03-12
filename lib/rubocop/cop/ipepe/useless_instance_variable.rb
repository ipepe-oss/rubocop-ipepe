module RuboCop
  module Cop
    module Ipepe
      class UselessInstanceVariable < ::RuboCop::Cop::Base
        MSG = "Use local variable instead of instance variable that's only used within one method".freeze

        def on_ivasgn(node)
          # Get the instance variable name
          ivar_name = node.children.first
          
          # Find the method that contains this assignment
          method_node = find_enclosing_method(node)
          return unless method_node
          
          # Check if this instance variable is only used within this method and its called private methods
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

          # Check if all usages are within this method or private methods it calls
          method_and_called_methods = [method_node]
          
          # Find private methods called from this method
          find_called_private_methods(method_node, class_node).each do |called_method|
            method_and_called_methods << called_method
          end

          # Check if all instance variable usages are within these methods
          ivar_usages.all? do |usage|
            method_and_called_methods.any? { |method| method.cover?(usage) }
          end
        end

        def find_called_private_methods(method_node, class_node)
          called_methods = []
          
          # Find all method calls in the current method
          method_node.each_descendant(:send) do |send_node|
            next if send_node.receiver # Only consider calls without explicit receiver
            
            method_name = send_node.method_name
            
            # Find the corresponding method definition in the class
            class_node.each_descendant(:def) do |def_node|
              if def_node.method_name == method_name && 
                 is_private_method?(def_node, class_node)
                called_methods << def_node
              end
            end
          end
          
          called_methods
        end

        def is_private_method?(method_node, class_node)
          # Find if this method is defined after a 'private' keyword
          private_found = false
          
          class_node.each_child_node do |node|
            if node.send_type? && node.method_name == :private && node.arguments.empty?
              private_found = true
            elsif node.def_type?
              if node == method_node
                return private_found
              end
            end
          end
          
          false
        end
      end
    end
  end
end