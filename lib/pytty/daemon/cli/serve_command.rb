# frozen_string_literal: true

require_relative "../api/server"
module Pytty
  module Daemon
    module Cli
      class ServeCommand < Clamp::Command
        def execute
          puts "🚽 pyttyd #{Pytty::VERSION}"

          url_parts = ["http://"]
          url_parts << if ENV["PYTTY_BIND"]
            ENV["PYTTY_BIND"]
          else
            "127.0.0.1"
          end
          url_parts << ":"
          url_parts << if ENV["PYTTY_PORT"]
            if ENV["PYTTY_PORT"] == "PORT"
              ENV.fetch "PORT"
            else
              ENV["PYTTY_PORT"]
            end
          else
            "1234"
          end

          Async::Reactor.run do
            Pytty::Daemon.load
            Pytty::Daemon::Api::Server.run url: url_parts.join("")
          end
        end
      end
    end
  end
end

