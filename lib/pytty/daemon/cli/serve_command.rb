# frozen_string_literal: true

require_relative "../api/server"
module Pytty
  module Daemon
    module Cli
      class ServeCommand < Clamp::Command
        def execute
          s = Pytty::Daemon::Api::Server.new
          s.run
        end
      end
    end
  end
end

