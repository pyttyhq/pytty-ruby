require "falcon"
require_relative "router"
require_relative "chunk"

module Pytty
  module Daemon
    module Api
      class Server
        def initialize
        end

        def run
          rack_app = Rack::Builder.new do
            #use Rack::CommonLogger

            map "/chunk" do
              run Chunk.new
            end
            map "/v1" do
              run Router.new
            end
          end

          app = Falcon::Server.middleware rack_app, verbose: true

          endpoint = Async::HTTP::URLEndpoint.parse "http://0.0.0.0:1234"
          bound_endpoint = Async::Reactor.run do
            Async::IO::SharedEndpoint.bound(endpoint)
          end.result

          server = Falcon::Server.new(app, bound_endpoint, endpoint.protocol, endpoint.scheme)
          Async::Reactor.run do
            server.run
            puts "serving..."
          end
        end
      end
    end
  end
end