# frozen_string_literal: true

require_relative "../api/server"
module Pytty
  module Daemon
    module Cli
      class ServeCommand < Clamp::Command
        def execute
          puts "🚽 pyttyd #{Pytty::VERSION}"

          url_parts = ["http://"]
          url_parts << if ENV["PYTTYD_BIND"]
            ENV["PYTTYD_BIND"]
          else
            "127.0.0.1"
          end
          url_parts << ":"
          url_parts << if ENV["PYTTYD_PORT"]
            if ENV["PYTTYD_PORT"] == "PORT"
              ENV.fetch "PORT"
            else
              ENV["PYTTYD_PORT"]
            end
          else
            "1234"
          end

          Async::Reactor.run do |task|
            Pytty::Daemon.load
            server_task = task.async do
              Pytty::Daemon::Api::Server.run url: url_parts.join("")
            end

            shutdown = lambda do |signo|
              puts "\r"
              puts "Got: #{Signal.signame(signo)}"
              server_task.stop
              Pytty::Daemon.yields.each do |id,process_yield|
                process_yield.signal "kill"
                puts id
              end
              puts "bye."
            end

            Signal.trap "INT", shutdown
            Signal.trap "TERM", shutdown
          end
        end
      end
    end
  end
end
