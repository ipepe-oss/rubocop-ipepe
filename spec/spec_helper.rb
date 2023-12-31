require "simplecov"

SimpleCov.start do
  add_filter "lib/rubocop/ipepe/version.rb"
end

require "rubocop-ipepe"
require "rubocop/rspec/support"

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense

  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.raise_on_warning = true
  config.fail_if_no_examples = true

  config.order = :random
  Kernel.srand config.seed
end
