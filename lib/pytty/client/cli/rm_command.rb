# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class RmCommand < Clamp::Command
        parameter "[ID] ...", "id"
        option ["--all"], :flag, "all"

        def execute
          ids = if all?
            process_yield_jsons = Async.run do
              Pytty::Client::Api::Ps.run
            end.wait
            process_yield_jsons.map do |json|
              json.fetch("id")
            end
          else
            id_list
          end

          Async.run do
            internet = Async::HTTP::Internet.new
            headers = [['accept', 'application/json']]
            body = {}.to_json

            for id in ids do
              response = internet.post("http://localhost:1234/v1/rm/#{id}", headers, [body])
              puts id
            end
          ensure
            internet.close
          end
        end
      end
    end
  end
end

