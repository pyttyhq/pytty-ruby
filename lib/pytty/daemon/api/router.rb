require "mustermann"
require "json"

module Pytty
  module Daemon
    module Api
      class Router
        def call(env)
          req = Rack::Request.new(env)

          params = Mustermann.new('/:component(/?:id)?').params(req.path_info)
          body = begin
            JSON.parse(req.body.read)
          rescue
          end

          resp = case params["component"]
          when "stdin"
            c = body["c"]
            Pytty::Daemon.yields[params["id"]].stdin.enqueue c
            [200, {"Content-Type" => "text/html"}, ["ok"]]
          when "stream"
            if env["HTTP_UPGRADE"] == "websocket"
              handler = Pytty::Daemon::Components::WebSocketHandler.new(env)
              handler.handle
            end

            [404, {"Content-Type" => "text/html"}, ["websocket only"]]
          when "attach"
            task = Async::Task.current
            body = Async::HTTP::Body::Writable.new

            task.async do |task|
              Pytty::Daemon.yields[params["id"]].stdouts << body
              loop do
                task.sleep 0.1
              end
            rescue Exception => ex
              p ex
            ensure
              puts "closing body"
              body.close
            end

            [200, {'content-type' => 'text/html; charset=utf-8'}, body]
          when "run","yield","ps","rm","kill","spawn","signal"
            status, output = Pytty::Daemon::Components::Handler.handle component: params["component"], id: params["id"], params: body
            [status, {"Content-Type" => "application/json"}, [output.to_json]]
          when "ws"
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