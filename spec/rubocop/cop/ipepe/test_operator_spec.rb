require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::TestOperator, :config do
  let(:config) { RuboCop::Config.new }

  it "registers an offense when using `#bad_method`" do
    expect_offense(<<~RUBY)
      bad_method
      ^^^^^^^^^^ Use `#good_method` instead of `#bad_method`.
    RUBY
  end

  it "does not register an offense when using `#good_method`" do
    expect_no_offenses(<<~RUBY)
      good_method
    RUBY
  end
end
