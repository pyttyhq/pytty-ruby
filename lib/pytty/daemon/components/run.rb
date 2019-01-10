# frozen_string_literal: true

module Pytty
  module Daemon
    module Components
      class Run
        def initialize(cmd:)
          @cmd = cmd
        end

        def run
          cmd_string = @cmd.join(" ")
          `#{cmd_string}`
        end
      end
    end
  end
end

