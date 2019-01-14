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
          when "stdout"
            process_yield = Pytty::Daemon.yields[params["id"]]
            return [404, {'content-type' => 'text/html; charset=utf-8'}, ["does not exist"]] unless process_yield

            body = Async::HTTP::Body::Writable.new

            begin
              our_stdout = process_yield.stdout.dup
              while c = our_stdout.read
                body.write c
              end
            rescue Exception => ex
              p ex
            ensure
              body.close
            end

            [200, {'content-type' => 'text/html; charset=utf-8'}, body]
          when "attach"
            process_yield = Pytty::Daemon.yields[params["id"]]
            return [404, {'content-type' => 'text/html; charset=utf-8'}, ["does not exist"]] unless process_yield

            puts "got attach: #{req.object_id}"
            body = Async::HTTP::Body::Writable.new

            Async::Task.current.async do |task|
              notification = process_yield.add_stdout body
              notification.wait
            rescue Exception => ex
              puts "----"
              p ["attach", ex]
            ensure
              puts "closing attach: #{req.object_id}"
              body.close
            end

            [200, {'content-type' => 'text/html; charset=utf-8'}, body]
          when "ps","yield"
            status, output = Pytty::Daemon::Components::Handler.handle component: params["component"], params: body
            [status, {"Content-Type" => "application/json"}, [output.to_json]]
          when "spawn","rm","signal","stdin"
            status, output = Pytty::Daemon::Components::YieldHandler.handle component: params["component"], id: params["id"], params: body
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