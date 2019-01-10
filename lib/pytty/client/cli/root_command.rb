# frozen_string_literal: true

module Pytty
  module Client
    module Cli
      class RootCommand < Clamp::Command
        banner "🧻  pytty #{Pytty::VERSION}"

        option ['-v', '--version'], :flag, "Show version information" do
          puts Pytty::VERSION
          exit 0
        end

        subcommand ["version"], "Show version information", Pytty::Common::Cli::VersionCommand
        subcommand ["run"], "run", RunCommand

        def self.run
          super
        rescue StandardError => exc
          warn exc.message
          warn exc.backtrace.join("\n")
        end
      end
    end
  end
end

