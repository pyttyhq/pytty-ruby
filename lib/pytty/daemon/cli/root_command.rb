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
        subcommand ["serve"], "serve", ServeCommand

        def self.run
          if ARGV.size == 0
            ServeCommand.run
          else
            super
          end
        rescue StandardError => exc
          warn exc.message
          warn exc.backtrace.join("\n")
        end
      end
    end
  end
end

