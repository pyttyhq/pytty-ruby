require "falcon"
require_relative "router"

module Pytty
  module Daemon
    module Api
      class Server
        def self.run(url:)
          rack_app = Rack::Builder.new do
            map "/v1" do
              run Router.new
            end
          end

          app = Falcon::Server.middleware rack_app, verbose: true

          endpoint = Async::HTTP::URLEndpoint.parse url
          bound_endpoint = Async::IO::SharedEndpoint.bound(endpoint)

          server = Falcon::Server.new(app, bound_endpoint, endpoint.protocol, endpoint.scheme)
          server.run
          puts "serving at #{url}"
        end
      end
    end
  end
end