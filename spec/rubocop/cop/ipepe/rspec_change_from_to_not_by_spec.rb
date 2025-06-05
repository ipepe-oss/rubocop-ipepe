require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::RspecChangeFromToNotBy, :config do
  let(:config) do
    RuboCop::Config.new("AllCops" => {
                          "DisplayCopNames" => true
                        })
  end

  it "registers an offense when using change.by" do
    expect_offense(<<~RUBY, prefix: " " * 19)
      expect { test }.to change { count }.by(1)
      _{prefix}^^^^^^^^^^^^^^^^^^^^^^ Ipepe/RspecChangeFromToNotBy: Prefer `change { }.from().to()` over `change { }.by()`
    RUBY
  end

  it "registers an offense with not_to" do
    expect_offense(<<~RUBY, prefix: " " * 23)
      expect { test }.not_to change { count }.by(1)
      _{prefix}^^^^^^^^^^^^^^^^^^^^^^ Ipepe/RspecChangeFromToNotBy: Prefer `change { }.from().to()` over `change { }.by()`
    RUBY
  end

  it "does not register an offense when using from/to" do
    expect_no_offenses(<<~RUBY)
      expect { test }.to change { count }.from(0).to(1)
    RUBY
  end
end
