# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Ipepe::InstanceVariableUsage, :config do
  let(:config) { RuboCop::Config.new }

  context 'when checking files in app/services' do
    let(:service_file_path) { 'app/services/test_service.rb' }

    before do
      # Manually create and assign a ProcessedSource instance to the cop for this context.
      # `cop` is the subject of the spec tests, provided by RuboCop::RSpec::ExpectOffense.
      # `inspect_source` uses this `cop` instance.
      # We need to ensure `cop.processed_source` returns an object with the correct `file_path`.
      # Note: The actual source content for this dummy ProcessedSource might not be critical
      # if `inspect_source` itself parses the code given to it and the cop only uses
      # `processed_source.file_path`. However, providing some valid Ruby code is safer.
      source_buffer = ::Parser::Source::Buffer.new(service_file_path)
      source_buffer.source = "class DummyService; end" # Dummy source
      # Assuming the project's Ruby version is compatible with this.
      # The version might be available from `cop.target_ruby_version`.
      processed_source_instance = ::RuboCop::ProcessedSource.new(source_buffer.source, cop.target_ruby_version, service_file_path)
      allow(cop).to receive(:processed_source).and_return(processed_source_instance)
    end

    it 'does not register an offense for instance variable usage inside initialize' do
      expect_no_offenses(<<~RUBY, service_file_path)
        class SomeService
          def initialize
            @foo = 1
            puts @foo
          end
        end
      RUBY
    end

    it 'does not register an offense for instance variable usage inside call' do
      expect_no_offenses(<<~RUBY, service_file_path)
        class SomeService
          def initialize
            @foo = 1
          end

          def call
            @bar = @foo + 1
            puts @bar
          end
        end
      RUBY
    end

    it 'registers an offense for instance variable read outside initialize and call' do
      expect_offense(<<~RUBY, service_file_path)
        class SomeService
          def initialize
            @foo = 1
          end

          def other_method
            puts @foo
                 ^^^^ Ipepe/InstanceVariableUsage: Instance variables should only be used inside initialize and call methods in services.
          end

          def call
            # no-op
          end
        end
      RUBY
    end

    it 'registers an offense for instance variable assignment outside initialize and call' do
      expect_offense(<<~RUBY, service_file_path)
        class SomeService
          def initialize
            # no-op
          end

          def other_method
            @bar = 2
            ^^^^^^^^ Ipepe/InstanceVariableUsage: Instance variables should only be used inside initialize and call methods in services.
          end

          def call
            # no-op
          end
        end
      RUBY
    end

    it 'registers an offense with the correct message' do
      expect_offense(<<~RUBY, service_file_path)
        class SomeService
          def helper
            @baz = 3
            ^^^^^^^^ Ipepe/InstanceVariableUsage: Instance variables should only be used inside initialize and call methods in services.
          end
        end
      RUBY
    end
  end

  context 'when checking files outside app/services' do
    # For these tests, inspect_source will be called with a filename that
    # does not match the service pattern. The cop's `relevant_file?` method,
    # which now uses `processed_source.file_path`, will correctly identify this.
    # The `allow_any_instance_of(described_class).to receive(:relevant_file?).and_return(true)`
    # from the other context needs to be overridden or not active here.
    # RSpec hooks like `before` are scoped, so the `before` block in the parent context
    # should not interfere here if this context doesn't have its own `before` that
    # would re-apply such a mock.

    # To be absolutely sure the `relevant_file?` in the parent context is not affecting these,
    # we can explicitly reset it for this context, or rely on RSpec's scoping.
    # The `inspect_source` helper from `RuboCop::RSpec::ExpectOffense` takes a file path
    # argument, which sets `processed_source.file_path`.

    it 'does not register an offense for instance variable usage' do
      expect_no_offenses(<<~RUBY, 'app/models/user.rb')
        class User
          def initialize
            @name = "Test"
          end

          def display_name
            puts @name
          end
        end
      RUBY
    end

    it 'does not register an offense for instance variable assignment' do
      expect_no_offenses(<<~RUBY, 'app/models/user.rb')
        class User
          attr_reader :name
          def initialize(name)
            @name = name
          end

          def set_name(new_name)
            @name = new_name
          end
        end
      RUBY
    end
  end
end
