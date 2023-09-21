require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::AlphabeticalArrayOfStrings, :config do
  let(:config) do
    RuboCop::Config.new("AllCops" => {
                          "DisplayCopNames" => true
                        })
  end
  let(:good_code) do
    <<~RUBY
      ["a", "b", "c"]
    RUBY
  end
  let(:bad_code) do
    <<~RUBY
      ["b", "a", "c"]
    RUBY
  end
  let(:not_relevant_codes) do
    [
      "['b', 'a', 1]",
      "[1, 'b', 'a']",
      "[1, 2, 3]",
      '["b", "a", ["c"]]',
      '["b", "a", {"c": 1}]',
      '["b", "a", true]',
      '["b", "a", a + b]',
      '["b", "a", a || b]',
      '["b", "a", a && b]',
      '["b", "a", Hash.new]',
      '["b", "a", Array.new]',
      '["b", "a", 1..2]',
      '["b", "a", 1...2]',
      '["b", "a", 1.0]',
      '["b", "a", 1e10]',
      '["b", "a", 1e-10]'
    ]
  end

  it "registers an offense when using bad code" do
    expect_offense <<~RUBY
      ["b", "a", "c"]
      ^^^^^^^^^^^^^^^ Ipepe/AlphabeticalArrayOfStrings: Ensure that strings in array are in alphabetical order
    RUBY
  end

  it "does not register an offense for good_code" do
    expect_no_offenses(good_code)
  end

  it "autocorrects bad_code into good_code" do
    expect(autocorrect_source(bad_code)).to eq(good_code)
  end

  it "does not register an offense for not_relevant_codes" do
    not_relevant_codes.each do |code|
      expect_no_offenses(code)
    end
  end
end
