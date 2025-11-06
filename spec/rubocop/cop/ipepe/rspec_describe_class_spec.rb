# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::RspecDescribeClass, :config do
  let(:config) do
    RuboCop::Config.new("AllCops" => {
                          "DisplayCopNames" => true
                        })
  end

  it "registers an offense when describe uses a string" do
    expect_offense(<<~RUBY)
      describe "MyClass" do
               ^^^^^^^^^^ Ipepe/RspecDescribeClass: RSpec top-level `describe` should specify a class constant, not a string. This helps with rspec-big-infer.
      end
    RUBY
  end

  it "registers an offense when describe uses a string with special characters" do
    expect_offense(<<~RUBY)
      describe "#method_name" do
               ^^^^^^^^^^^^^^ Ipepe/RspecDescribeClass: RSpec top-level `describe` should specify a class constant, not a string. This helps with rspec-big-infer.
      end
    RUBY
  end

  it "does not register an offense when describe uses a class constant" do
    expect_no_offenses(<<~RUBY)
      describe MyClass do
      end
    RUBY
  end

  it "does not register an offense when describe uses a namespaced class constant" do
    expect_no_offenses(<<~RUBY)
      describe MyModule::MyClass do
      end
    RUBY
  end

  it "does not register an offense for nested describe blocks with strings" do
    expect_no_offenses(<<~RUBY)
      describe MyClass do
        describe "#method_name" do
        end
      end
    RUBY
  end

  it "does not register an offense for context blocks with strings" do
    expect_no_offenses(<<~RUBY)
      describe MyClass do
        context "when something happens" do
        end
      end
    RUBY
  end

  it "registers an offense for top-level describe with string even with nested blocks" do
    expect_offense(<<~RUBY)
      describe "MyClass" do
               ^^^^^^^^^^ Ipepe/RspecDescribeClass: RSpec top-level `describe` should specify a class constant, not a string. This helps with rspec-big-infer.
        context "nested" do
        end
      end
    RUBY
  end

  it "does not register an offense when describe has no arguments" do
    expect_no_offenses(<<~RUBY)
      describe do
      end
    RUBY
  end
end
