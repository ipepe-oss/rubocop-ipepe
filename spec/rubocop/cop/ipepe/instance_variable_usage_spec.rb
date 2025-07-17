# frozen_string_literal: true

require_relative '../../../spec_helper' # Ensure spec_helper runs first
require 'rubocop' # Then ensure RuboCop base is loaded
require 'rubocop-ipepe' # Then ensure the custom cops are loaded

RSpec.describe RuboCop::Cop::Ipepe::InstanceVariableUsage, :config do
  let(:cop_config) { {} } # Default to empty hash, specific contexts can override
  let(:config) do
    # Initialize RuboCop::Config with the cop_config for the specific cop
    RuboCop::Config.new('Ipepe/InstanceVariableUsage' => cop_config)
  end

  context 'when checking files with default configuration (in app/services)' do
    # These tests run with cop_config = {}, so defaults in the cop apply.
    let(:service_file_path) { 'app/services/test_service.rb' }
    # Removed the before block that mocked `cop.processed_source`.
    # Relying on `inspect_source(code, filename)` to set this up.

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
  end

  context 'with custom ExcludedPaths' do
    let(:cop_config) { { 'ExcludedPaths' => ['app/services/base_service.rb'] } } # Uses default IncludedPaths
    let(:excluded_file_path) { 'app/services/base_service.rb' }
    let(:included_file_path) { 'app/services/another_service.rb' }

    it 'does not register an offense for instance variable usage in app/services/base_service.rb (excluded)' do
      expect_no_offenses(<<~RUBY, excluded_file_path)
        class BaseService
          def run
            @ivar = :excluded
          end
        end
      RUBY
    end

    it 'registers an offense for instance variable usage in app/services/another_service.rb (included)' do
      # DEBUG code removed
      expect_offense(<<~RUBY, included_file_path)
        class AnotherService
          def run
            @ivar = :included
            ^^^^^^^^^^^^^^^^^ Instance variables should only be used inside initialize and call methods in services.
          end
        end
      RUBY
    end
  end

  context 'with custom IncludedPaths and ExcludedPaths' do
    let(:cop_config) do
      {
        'IncludedPaths' => ['app/workers/**/*.rb', 'app/special_services/**/*.rb'],
        'ExcludedPaths' => ['app/workers/base_worker.rb', 'app/special_services/base_*.rb']
      }
    end
    let(:included_worker_path) { 'app/workers/my_worker.rb' }
    let(:excluded_worker_path) { 'app/workers/base_worker.rb' }
    let(:included_service_path) { 'app/special_services/actual_service.rb' }
    let(:excluded_service_path) { 'app/special_services/base_utility_service.rb' }
    let(:other_service_path) { 'app/services/standard_service.rb' } # Should not be included

    # Tests for behavior (ivar, ivasgn, whitelisted methods) using one of the included paths
    # These were previously using `service_file_path` incorrectly in this context.
    # Corrected to use `included_worker_path` and `MyWorker` class.

    it 'does not register an offense for ivar in initialize in app/workers/my_worker.rb' do
      expect_no_offenses(<<~RUBY, included_worker_path)
        class MyWorker
          def initialize
            @foo = 1
            puts @foo
          end
        end
      RUBY
    end

    it 'CUSTOM_CONTEXT: does not register an offense for instance variable usage inside call' do # Was line 198
      expect_no_offenses(<<~RUBY, included_worker_path)
        class MyWorker
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

    it 'CUSTOM_CONTEXT: registers an offense for instance variable read outside initialize and call' do # Was line 213
      expect_offense(<<~RUBY, included_worker_path)
        class MyWorker
          def initialize
            @foo = 1
          end

          def other_method
            puts @foo
                 ^^^^ Instance variables should only be used inside initialize and call methods in services.
          end
        end
      RUBY
    end

    it 'CUSTOM_CONTEXT: registers an offense for instance variable assignment outside initialize and call' do # Was line 232
      expect_offense(<<~RUBY, included_worker_path)
        class MyWorker
          def initialize
            # no-op
          end

          def other_method
            @bar = 2
            ^^^^^^^^ Instance variables should only be used inside initialize and call methods in services.
          end
        end
      RUBY
    end

    it 'CUSTOM_CONTEXT: registers an offense with the correct message' do # Was line 251
      expect_offense(<<~RUBY, included_worker_path)
        class MyWorker
          def another_helper
            @baz = 3
            ^^^^^^^^ Instance variables should only be used inside initialize and call methods in services.
          end
        end
      RUBY
    end

    # Original specific path tests for this context
    # These tests are specific to this context and already use correct path variables.
    # The tests above were generic behavior tests that were copied and needed path/class updates.
    it 'registers an offense in app/workers/my_worker.rb' do
      expect_offense(<<~RUBY, included_worker_path)
        class MyWorker
          def work
            @data = 'work_data'
            ^^^^^^^^^^^^^^^^^^^ Instance variables should only be used inside initialize and call methods in services.
          end
        end
      RUBY
    end

    it 'does not register an offense in app/workers/base_worker.rb (excluded)' do
      expect_no_offenses(<<~RUBY, excluded_worker_path)
        class BaseWorker
          def work
            @data = 'base_data'
          end
        end
      RUBY
    end

    it 'registers an offense in app/special_services/actual_service.rb' do
      expect_offense(<<~RUBY, included_service_path)
        class ActualService
          def process
            @item = 'item_data'
            ^^^^^^^^^^^^^^^^^^^ Instance variables should only be used inside initialize and call methods in services.
          end
        end
      RUBY
    end

    it 'does not register an offense in app/special_services/base_utility_service.rb (excluded by glob)' do
      expect_no_offenses(<<~RUBY, excluded_service_path)
        class BaseUtilityService
          def process
            @item = 'base_item_data'
          end
        end
      RUBY
    end

    it 'does not register an offense in app/services/standard_service.rb (not in IncludedPaths)' do
      expect_no_offenses(<<~RUBY, other_service_path)
        class StandardService
          def process
            @item = 'standard_item_data'
          end
        end
      RUBY
    end
    # Removed 4 redundant/incorrect tests that were here using service_file_path
  end

  context 'when checking files outside default configuration (e.g. app/models)' do
    # These tests also run with cop_config = {}, so defaults in the cop apply.
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

    it 'does not register an offense for instance variable assignment in app/models/user.rb' do
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

  context 'with custom IncludedPaths' do
    let(:cop_config) { { 'IncludedPaths' => ['app/jobs/**/*.rb'] } }
    let(:job_file_path) { 'app/jobs/my_job.rb' }
    let(:service_file_path) { 'app/services/ignored_service.rb' } # Corrected this let variable name for clarity

    it 'registers an offense for ivasgn in app/jobs/my_job.rb' do # Changed test name for clarity
      expect_offense(<<~RUBY, job_file_path)
        class MyJob
          def perform
            @ivar = 1
            ^^^^^^^^^ Instance variables should only be used inside initialize and call methods in services.
          end
        end
      RUBY
    end

    it 'does not register an offense for ivasgn in app/services/ignored_service.rb' do # Changed test name for clarity
      expect_no_offenses(<<~RUBY, service_file_path)
        class IgnoredService
          def perform
            @ivar = 1 # This is an assignment, not just "usage"
          end
        end
      RUBY
    end
  end
end
