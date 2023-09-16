require "rubocop"

require_relative "rubocop/ipepe"
require_relative "rubocop/ipepe/version"
require_relative "rubocop/ipepe/inject"

RuboCop::Ipepe::Inject.defaults!

require_relative "rubocop/cop/ipepe_cops"
