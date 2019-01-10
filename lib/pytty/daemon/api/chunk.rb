require "falcon"
require_relative "router"

module Pytty
  module Daemon
    module Api
      class Chunk

        def call(env)
          task = Async::Task.current
          body = Async::HTTP::Body::Writable.new
          task.async do |task|
            10.times do
              body.write "hello"
              task.sleep 0.5
            end
          rescue Exception => ex
            p ex
          ensure
            body.close
          end

          [200, {'content-type' => 'text/html; charset=utf-8'}, body]
        end
      end
    end
  end
end