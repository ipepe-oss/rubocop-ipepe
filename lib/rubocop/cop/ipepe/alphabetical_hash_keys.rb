module RuboCop
  module Cop
    module Ipepe
      class AlphabeticalHashKeys < ::RuboCop::Cop::Base
        extend AutoCorrector
        MSG = "Ensure that keys in hash are in alphabetical order".freeze
        # SupportedStyles: ['symbols_only', 'strings_only', 'symbols_and_strings']
        include ConfigurableEnforcedStyle

        def on_hash(node)
          keys = node.children.select(&:pair_type?).map(&:key)
          sorted_keys = keys.sort_by(&:value)

          return if keys == sorted_keys

          add_offense(node) do |corrector|
            join_keys_with = " "
            join_keys_with = "\n " if node.source.include?("\n")

            corrector.replace(
              node,
              [
                "{",
                sorted_keypairs(node, sorted_keys).join(",#{join_keys_with}"),
                "}"
              ].join(join_keys_with)
            )
          end
        end

        private

        def sorted_keypairs(node, sorted_keys)
          sorted_keys.map do |k|
            keypair = node.children.find { |n| n.key == k }
            if keypair.key.str_type?
              "#{keypair.key.source} => #{keypair.value.source}"
            elsif keypair.key.sym_type?
              "#{keypair.key.source}: #{keypair.value.source}"
            else
              raise "Unknown key type: #{keypair.key.type}"
            end
          end
        end
      end
    end
  end
end
