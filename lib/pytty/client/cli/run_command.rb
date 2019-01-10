# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class RunCommand < Clamp::Command
        parameter "CMD ...", "command"
        def execute
          Async.run do
            internet = Async::HTTP::Internet.new
            headers = [['accept', 'application/json']]
            body = {
              cmd: cmd_list
            }.to_json

            response = internet.post("http://localhost:1234/v1/run", headers, [body])
            puts response.read
          ensure
            internet.close
          end
        end
      end
    end
  end
end

