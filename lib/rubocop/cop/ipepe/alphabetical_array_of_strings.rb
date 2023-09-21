module RuboCop
  module Cop
    module Ipepe
      class AlphabeticalArrayOfStrings < ::RuboCop::Cop::Base
        extend AutoCorrector
        MSG = "Ensure that strings in array are in alphabetical order".freeze

        def on_array(node)
          str_type_hash = {}
          node.children.each do |n|
            str_type_hash[n.str_type?] ||= 0
            str_type_hash[n.str_type?] += 1
          end

          return if str_type_hash.size != 1 || str_type_hash[true].nil?

          strings = node.children.map(&:value)
          sorted_strings = strings.sort

          return if strings == sorted_strings

          add_offense(node) do |corrector|
            corrector.replace(node, "[#{sorted_strings.map { |s| "\"#{s}\"" }.join(', ')}]")
          end
        end
      end
    end
  end
end
