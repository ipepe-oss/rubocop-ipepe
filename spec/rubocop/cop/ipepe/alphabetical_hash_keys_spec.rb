require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::AlphabeticalHashKeys, :config do
  let(:config) do
    RuboCop::Config.new("AllCops" => {
                          "DisplayCopNames" => true,
                          "TargetRubyVersion" => "2.4"
                        })
  end
  context "with string keys" do
    let(:good_code) do
      <<~RUBY
        { "a" => 1, "b" => 2, "c" => 3 }
      RUBY
    end
    let(:bad_code) do
      <<~RUBY
        { "b" => 2, "a" => 1, "c" => 3 }
      RUBY
    end

    it "registers an offense when using bad code" do
      expect_offense <<~RUBY
        { "b" => 2, "a" => 1, "c" => 3 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ipepe/AlphabeticalHashKeys: Ensure that keys in hash are in alphabetical order
      RUBY
    end

    it "does not register an offense for good_code" do
      expect_no_offenses(good_code)
    end

    it "autocorrects bad_code into good_code" do
      expect(autocorrect_source(bad_code)).to eq(good_code)
    end
  end

  context "with symbol keys" do
    let(:good_code) do
      <<~RUBY
        { a: 1, b: 2, c: 3 }
      RUBY
    end
    let(:bad_code) do
      <<~RUBY
        { b: 2, a: 1, c: 3 }
      RUBY
    end

    it "registers an offense when using bad code" do
      expect_offense <<~RUBY
        {
        ^ Ipepe/AlphabeticalHashKeys: Ensure that keys in hash are in alphabetical order
          b: 2,
          a: 1,
          c: 3
        }
      RUBY
    end

    it "does not register an offense for good_code" do
      expect_no_offenses(good_code)
    end

    it "autocorrects bad_code into good_code" do
      expect(autocorrect_source(bad_code)).to eq(good_code)
    end
  end
end
