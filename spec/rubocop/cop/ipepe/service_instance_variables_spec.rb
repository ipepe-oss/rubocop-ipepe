require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::ServiceInstanceVariables do
  def config
    RuboCop::Config.new("AllCops" => { "DisplayCopNames" => true })
  end

  def cop
    described_class.new(config)
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
end
