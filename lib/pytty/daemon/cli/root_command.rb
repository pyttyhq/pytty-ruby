# frozen_string_literal: true

module Pytty
  module Daemon
    module Cli
      class RootCommand < Clamp::Command
        banner "🚽 pyttyd #{Pytty::VERSION}"

        option ['-v', '--version'], :flag, "Show version information" do
          puts Pytty::VERSION
          exit 0
        end

        subcommand ["version"], "Show version information", Pytty::Common::Cli::VersionCommand

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

