# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class KillCommand < Clamp::Command
        parameter "ID ...", "id"

        def execute
          Async.run do
            internet = Async::HTTP::Internet.new
            headers = [['accept', 'application/json']]
            body = {}.to_json

            for id in id_list do
              response = internet.post("http://localhost:1234/v1/kill/#{id}", headers, [body])
              puts response.read
            end
          ensure
            internet.close
          end
        end
      end
    end
  end
end

