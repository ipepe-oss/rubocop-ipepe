require "spec_helper"

RSpec.describe RuboCop::Cop::Ipepe::RailsNonStandardActions, :config do
  let(:config) do
    RuboCop::Config.new("AllCops" => {
                          "DisplayCopNames" => true
                        })
  end

  context "when class is a controller" do
    it "registers an offense for non-standard action" do
      expect_offense <<~RUBY
        class BooksController
          def download
              ^^^^^^^^ Ipepe/RailsNonStandardActions: Non-standard action 'download' should be moved to a sub-controller (e.g., DownloadController)
          end
        end
      RUBY
    end

    it "registers multiple offenses for multiple non-standard actions" do
      expect_offense <<~RUBY
        class BooksController
          def download
              ^^^^^^^^ Ipepe/RailsNonStandardActions: Non-standard action 'download' should be moved to a sub-controller (e.g., DownloadController)
          end

          def export
              ^^^^^^ Ipepe/RailsNonStandardActions: Non-standard action 'export' should be moved to a sub-controller (e.g., ExportController)
          end
        end
      RUBY
    end

    it "does not register an offense for standard actions" do
      expect_no_offenses <<~RUBY
        class BooksController
          def index
          end

          def show
          end

          def new
          end

          def edit
          end

          def create
          end

          def update
          end

          def destroy
          end
        end
      RUBY
    end
  end

  context "when class is not a controller" do
    it "does not register an offense for non-standard methods" do
      expect_no_offenses <<~RUBY
        class Book
          def download
          end

          def export
          end
        end
      RUBY
    end
  end

  context "with nested controller class" do
    it "registers an offense for non-standard action in nested controller" do
      expect_offense <<~RUBY
        module Admin
          class BooksController
            def download
                ^^^^^^^^ Ipepe/RailsNonStandardActions: Non-standard action 'download' should be moved to a sub-controller (e.g., DownloadController)
            end
          end
        end
      RUBY
    end
  end

  context "with mixed standard and non-standard actions" do
    it "only registers offenses for non-standard actions" do
      expect_offense <<~RUBY
        class BooksController
          def index
          end

          def download
              ^^^^^^^^ Ipepe/RailsNonStandardActions: Non-standard action 'download' should be moved to a sub-controller (e.g., DownloadController)
          end

          def show
          end

          def export
              ^^^^^^ Ipepe/RailsNonStandardActions: Non-standard action 'export' should be moved to a sub-controller (e.g., ExportController)
          end
        end
      RUBY
    end
  end
end