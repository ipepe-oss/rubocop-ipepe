require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::TernaryOperator, :config do
  let(:config) { RuboCop::Config.new }
  let(:good_code) do
    <<~RUBY
      if true
        1
        else
        2
      end
    RUBY
  end
  let(:bad_code) do
    <<~RUBY
      true ? 1 : 2
    RUBY
  end

  it "registers an offense when using ternary operator" do
    expect_offense(<<~RUBY)
      bad_method
      ^^^^^^^^^^ Use `#good_method` instead of `#bad_method`.
    RUBY
  end

  it "does not register an offense when regular if" do
    expect_no_offenses(good_code)
  end

  it "autocorrects bad_code into good_code" do
    expect(autocorrect_source(bad_code)).to eq(good_code)
  end
end
