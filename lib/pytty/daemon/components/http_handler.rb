# frozen_string_literal: true
require "rack/request"
require "mustermann"

module Pytty
  module Daemon
    module Components
      class HttpHandler
        def initialize(env)
          @env = env
        end

        def handle
          req = Rack::Request.new(@env)
          body = begin
            JSON.parse(req.body.read)
          rescue
          end

          params = Mustermann.new('/:component(/?:id)?').params(req.path_info)
          case params.fetch("component")
          when "rm"
            id = params["id"]

            process_yield = Pytty::Daemon.yields[id]
            unless process_yield
              return [404, nil]
            else
              return [200, process_yield]
            end
          end

          case req.path_info
          when "/kill"
            p req
            return [200, {}]
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

