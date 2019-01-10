require_relative "web_sockets"
require_relative "../components"

module Pytty
  module Daemon
    module Api
      class Router
        def call(env)
          req = Rack::Request.new(env)
          resp = case req.path_info
          when "/run"
            handler = Pytty::Daemon::Components::WebHandler.new(env)
            handler.handle

            [200, {"Content-Type" => "text/html"}, ["ok"]]
          when "/ws"
            if env["HTTP_UPGRADE"] == "websocket"
              ws = WebSockets.new env
              ws.handle
            end

            [200, {"Content-Type" => "text/html"}, ["ws"]]
          else
            [404, {"Content-Type" => "text/html"}, ["unknown: #{req.path_info}"]]
          end

          resp
        end
      end
    end
  end
end