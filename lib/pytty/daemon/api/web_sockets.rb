require 'async/websocket/server'

module Pytty
  module Daemon
    module Api
      class WebSockets
        @@connections = []
        def initialize(env)
          @env = env

          @connection = Async::WebSocket::Server.open(env)
          @@connections << @connection
        end

        def handle
          while message = @connection.next_event
            type = case message
            when WebSocket::Driver::OpenEvent
              puts "ws: open #{@env["REMOTE_ADDR"]}"
            when WebSocket::Driver::CloseEvent
              puts "ws: close #{@env["REMOTE_ADDR"]}"
              @@connections.delete @connection
            when WebSocket::Driver::MessageEvent
              puts "ws: message #{@env["REMOTE_ADDR"]}"
              @@connections.each do |connection|
                connection.send_message(message.data.reverse)
              end
            else
              raise "ws: unknown #{message.inspect}"
            end
          end
        end
      end
    end
  end
end