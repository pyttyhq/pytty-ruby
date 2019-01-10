# frozen_string_literal: true
require 'async/reactor'
require 'async/io/stream'
require 'async/http/url_endpoint'
require 'async/websocket/client'
require 'io/console'

module Pytty
  module Client
    module Cli
      class StreamCommand < Clamp::Command
        parameter "CMD ...", "command"
        def execute
          env = {
            "LINES" => IO.console.winsize.first.to_s,
            "COLUMNS" => IO.console.winsize.last.to_s
          }

          url = "ws://localhost:1234/v1/stream"
          endpoint = Async::HTTP::URLEndpoint.parse url
          Async::Reactor.run do |task|
            endpoint.connect do |socket|
              connection = Async::WebSocket::Client.new socket, url

              connection.send_message({
                cmd: cmd_list,
                env: env
              })

              while message = connection.next_message
                print message
              end
            end
          end
        end
      end
    end
  end
end

