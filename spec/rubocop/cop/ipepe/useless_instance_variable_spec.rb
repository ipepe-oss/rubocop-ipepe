require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::UselessInstanceVariable, :config do
  let(:config) do
    RuboCop::Config.new("AllCops" => {
                          "DisplayCopNames" => true
                        })
  end

  context "when instance variable is only used within one method" do
    it "registers an offense for instance variable that could be local" do
      expect_offense(<<~RUBY)
        class SomethingController < BaseController
          def create
            @service = Service.new
            ^^^^^^^^ Ipepe/UselessInstanceVariable: Use local variable instead of instance variable for better visibility and typo protection

            if @service.call
              render :create, locals: { }
            else
              render_failure_message
            end
          end

          private
          def render_failure_message
            render error: { title: 'Oops! Something went wrong', message: @service.error_message }
          end
        end
      RUBY
    end
  end

  context "when instance variable is used across multiple methods" do
    it "registers an offense for cross-method usage that could use local variables" do
      expect_offense(<<~RUBY)
        class SomethingController < BaseController
          def create
            @service = Service.new
            ^^^^^^^^ Ipepe/UselessInstanceVariable: Use local variable instead of instance variable for better visibility and typo protection

            if @service.call
              render :create, locals: { }
            else
              render_failure_message
            end
          end

          def update
            if @service.update(params)
              render :success
            end
          end

          private
          def render_failure_message
            render error: { title: 'Oops! Something went wrong', message: @service.error_message }
          end
        end
      RUBY
    end
  end

  context "when instance variable is only used within one method without private method calls" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class Example
          def process
            @data = fetch_data
            ^^^^^ Ipepe/UselessInstanceVariable: Use local variable instead of instance variable for better visibility and typo protection

            puts @data.length
          end
        end
      RUBY
    end
  end

  context "when instance variable is used in non-private methods" do
    it "registers an offense for cross-method usage" do
      expect_offense(<<~RUBY)
        class Example
          def setup
            @config = load_config
            ^^^^^^^ Ipepe/UselessInstanceVariable: Use local variable instead of instance variable for better visibility and typo protection
          end

          def process
            puts @config.value
          end
        end
      RUBY
    end
  end
end