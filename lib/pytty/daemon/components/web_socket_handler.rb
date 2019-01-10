# frozen_string_literal: true
require "rack/request"

module Pytty
  module Daemon
    module Components
      class WebSocketHandler
        def initialize(env)
          @env = env
        end

        def handle
          req = Rack::Request.new(@env)
          ws = Pytty::Daemon::Api::WebSockets.new(@env)
          ws.handle

          klass = case req.path_info
          when "/stream"
            Stream
          else
            raise "Unknown: #{req.path_info}"
          end
          params = ws.read
          body = begin
            JSON.parse(params)
          rescue Exception => ex
            p ex
          end

          obj = klass.new cmd: body.dig("cmd"), env: body.dig("env")
          obj.run stream: ws
        end
      end
    end
  end
end

