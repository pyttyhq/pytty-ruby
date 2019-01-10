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

          @messages = Async::Queue.new
          @writes = Async::Queue.new
        end

        def close
          @@connections.each do |connection|
            connection.close
          end
          @@connections = []
        end

        def read
          @messages.dequeue
        end

        def write(message)
          @writes.enqueue message
        end

        def handle
          Async::Task.current.async do
            while message = @connection.next_event
              type = case message
              when WebSocket::Driver::OpenEvent
                puts "ws: open #{@env["REMOTE_ADDR"]}"
              when WebSocket::Driver::CloseEvent
                puts "ws: close #{@env["REMOTE_ADDR"]}"
                @@connections.delete @connection
              when WebSocket::Driver::MessageEvent
                puts "ws: message #{@env["REMOTE_ADDR"]}"
                @messages.enqueue message.data
              else
                raise "ws: unknown #{message.inspect}"
              end
            end
          end

          Async::Task.current.async do |task|
            while message = @writes.dequeue
              @@connections.each do |connection|
                connection.send_message(message)
              rescue Exception => ex
                #TODO
              end
            end
          end
        end
      end
    end
  end
end