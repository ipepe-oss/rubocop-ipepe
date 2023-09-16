require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::TernaryOperator, :config do
  let(:config) do
    RuboCop::Config.new("AllCops" => {
      "DisplayCopNames" => true
    })
  end
  let(:good_code) do
    "if true\n1\nelse\n2\nend"
  end
  let(:bad_code) do
    "true ? 1 : 2"
  end

  it "registers an offense when using ternary operator" do
    expect_offense(<<~RUBY)
      true ? 1 : 2
      ^^^^^^^^^^^^ Ipepe/TernaryOperator: Use `if` instead of ternary operator.
    RUBY
  end

  it "does not register an offense when regular if" do
    expect_no_offenses(good_code)
  end

  it "autocorrects bad_code into good_code" do
    expect(autocorrect_source(bad_code)).to eq(good_code)
  end
end
