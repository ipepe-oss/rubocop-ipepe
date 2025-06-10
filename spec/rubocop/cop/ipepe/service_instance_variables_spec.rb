require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::ServiceInstanceVariables do
  def config(include_path = "app/services/**/*.rb")
    RuboCop::Config.new(
      "AllCops" => { "DisplayCopNames" => true },
      "Ipepe/ServiceInstanceVariables" => { "Include" => [include_path] }
    )
  end

  def cop(include_path = "app/services/**/*.rb")
    @cop ||= described_class.new(config(include_path))
  end

  it "registers an offense for instance variable outside initialize and call" do
    expect_offense(<<~RUBY, "app/services/test_service.rb")
      class TestService
        def initialize
          @foo = 1
        end

        def call
          @foo
        end

        def other
          @foo
          ^^^^ Ipepe/ServiceInstanceVariables: Do not use instance variables outside #initialize and #call
        end
      end
    RUBY
  end

  it "does not register an offense for initialize and call" do
    expect_no_offenses(<<~RUBY, "app/services/test_service.rb")
      class TestService
        def initialize
          @foo = 1
        end

        def call
          @foo
        end
      end
    RUBY
  end

  it "does not register an offense when file is outside included paths" do
    expect_no_offenses(<<~RUBY, "app/models/test_service.rb")
      class TestService
        def other
          @foo = 1
        end
      end
    RUBY
  end

  it "allows configuring additional paths" do
    @cop = described_class.new(config("app/models/**/*.rb"))
    expect_offense(<<~RUBY, "app/models/test_service.rb")
      class TestService
        def other
          @foo
          ^^^^ Ipepe/ServiceInstanceVariables: Do not use instance variables outside #initialize and #call
        end
      end
    RUBY
  end
end
