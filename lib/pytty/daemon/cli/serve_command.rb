# frozen_string_literal: true

require_relative "../api/server"
module Pytty
  module Daemon
    module Cli
      class ServeCommand < Clamp::Command
        option ["--url"], "URL", "url"

        def execute
          puts "🚽 pyttyd #{Pytty::VERSION}"

          url_parts = ["http://"]
          url_parts << if bind = ENV.get("PYTTY_BIND")
            bind
          else
            "127.0.0.1"
          end
          url_parts << if port = ENV.get("PYTTY_PORT")
            if port == "PORT"
              ENV.fetch "PORT"
            else
              "1234"
            end
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

