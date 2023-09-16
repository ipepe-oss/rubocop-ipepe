require_relative "lib/rubocop/ipepe/version"

Gem::Specification.new do |spec|
  spec.name          = "rubocop-ipepe"
  spec.version       = RuboCop::Ipepe::VERSION
  spec.authors       = ["Patryk Ptasinski"]
  spec.email         = ["patryk@ipepe.pl"]

  spec.summary       = "Opinionated RuboCop configuration used by ipepe."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/ipepe-oss/rubocop-ipepe"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}#changelog"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rubocop"
  spec.metadata["rubygems_mfa_required"] = "true"
end
