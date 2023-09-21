require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::MultipleConditionUnless, :config do
  let(:config) do
    RuboCop::Config.new("AllCops" => {
                          "DisplayCopNames" => true
                        })
  end
  context "with return" do
    let(:passing_code) do
      <<~RUBY
        return unless 1 == 2
      RUBY
    end
    let(:bad_code) do
      <<~RUBY
        return unless 1 == 2 && 3 != 4
      RUBY
    end

    it "registers an offense when there is more than one condition in unless" do
      expect_offense(<<~RUBY)
        return unless 1 == 2 && 3 != 4
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ipepe/MultipleConditionUnless: Use only one condition in unless or change to if
      RUBY
    end

    it "does not register an offense when using single condition unless" do
      expect_no_offenses(passing_code)
    end

    it "autocorrects bad_code into good_code" do
      expect(autocorrect_source(bad_code)).to eq("if !(1 == 2 && 3 != 4)\nreturn\nend\n")
    end
  end

  context "with body condition" do
    let(:passing_code) do
      <<~RUBY
        unless 1 == 2
          puts "hello"
        end
      RUBY
    end
    let(:bad_code) do
      <<~RUBY
        unless 1 == 2 && 3 != 4
          puts "hello"
        end
      RUBY
    end

    it "registers an offense when there is more than one condition in unless" do
      expect_offense(<<~RUBY)
        unless 1 == 2 && 3 != 4
        ^^^^^^^^^^^^^^^^^^^^^^^ Ipepe/MultipleConditionUnless: Use only one condition in unless or change to if
          puts "hello"
        end
      RUBY
    end

    it "does not register an offense when using single condition unless" do
      expect_no_offenses(passing_code)
    end

    it "autocorrects bad_code into good_code" do
      expect(autocorrect_source(bad_code)).to eq("if !(1 == 2 && 3 != 4)\nputs \"hello\"\nend\n")
    end
  end
end
