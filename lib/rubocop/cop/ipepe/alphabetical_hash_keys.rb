module RuboCop
  module Cop
    module Ipepe
      class AlphabeticalHashKeys < ::RuboCop::Cop::Base
        extend AutoCorrector
        MSG = "Ensure that keys in hash are in alphabetical order".freeze

        def on_hash(node) # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
          keys = node.children.select(&:pair_type?).map(&:key)
          sorted_keys = keys.sort_by do |k|
            if k.respond_to?(:value)
              k.value.to_s
            elsif k.respond_to?(:const_name)
              k.const_name.to_s
            end
          end
          return if cop_not_applicable?(keys, sorted_keys)

          add_offense(node) do |corrector|
            join_keys_with = " "
            join_keys_with = "\n " if node.source.include?("\n")

            corrector.replace(
              node,
              [
                ("{" if node.source.start_with?("{")),
                sorted_keypairs(node, sorted_keys).join(",#{join_keys_with}"),
                ("}" if node.source.end_with?("}"))
              ].compact.join(join_keys_with)
            )
          end
        end

        private

        def cop_not_applicable?(keys, sorted_keys) # rubocop:disable Metrics/PerceivedComplexity
          keys.empty? ||
            keys.one? ||
            (keys.none?(&:str_type?) && keys.none?(&:sym_type?) && keys.none?(&:const_type?)) ||
            keys == sorted_keys
        end

        def sorted_keypairs(node, sorted_keys)
          sorted_keys.map do |k|
            keypair = node.children.find { |n| n.key == k }
            if keypair.key.sym_type?
              "#{keypair.key.source}: #{keypair.value.source}"
            else
              "#{keypair.key.source} => #{keypair.value.source}"
            end
          end
        end
      end
    end
  end
end
