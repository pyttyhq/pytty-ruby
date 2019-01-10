# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'

module Pytty
  module Client
    module Cli
      class RunCommand < Clamp::Command
        def execute
          Async.run do
            internet = Async::HTTP::Internet.new
            headers = [['accept', 'application/json']]
            body = []
            response = internet.post("http://localhost:1234/v1/run", headers, body)
            response.read
          ensure
            internet.close
          end
        end
      end
    end
  end
end

