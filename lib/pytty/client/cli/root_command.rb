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
        subcommand ["yield"], "yield", YieldCommand
        subcommand ["ps"], "ps", PsCommand
        subcommand ["rm"], "rm", RmCommand
        subcommand ["spawn"], "spawn", SpawnCommand
        subcommand ["signal"], "signal", SignalCommand
        subcommand ["attach"], "attach", AttachCommand
        subcommand ["stdout"], "stdout", StdoutCommand
        subcommand ["stderr"], "stderr", StderrCommand
        subcommand ["status"], "status", StatusCommand
        subcommand ["port"], "port", PortCommand

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
