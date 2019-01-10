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
          case req.path_info
          when "/run"
            Run.new.run
          else
            raise "Unknown: #{req.path_info}"
          end
        end
      end
    end
  end
end

