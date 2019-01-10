# frozen_string_literal: true
require "rack/request"

module Pytty
  module Daemon
    module Components
      class WebHandler
        def initialize(env)
          @env = env
        end

        def handle
          req = Rack::Request.new(@env)
          body = begin
            JSON.parse(req.body.read)
          rescue
          end

          obj = case req.path_info
          when "/run"
            Run.new cmd: body.dig("cmd")
          when "/stream"
            Stream.new cmd: body.dig("cmd")
          else
            raise "Unknown: #{req.path_info}"
          end

          obj.run
        end
      end
    end
  end
end

