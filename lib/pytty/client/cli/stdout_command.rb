# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class StdoutCommand < Clamp::Command
        parameter "ID", "id"

        def execute
          Async.run do
            response, body = Pytty::Client::Api::Stdout.run id: id
            if response.status == 200
              puts body.read
            else
              puts body.read
              exit 1
            end
          end
        end
      end
    end
  end
end

