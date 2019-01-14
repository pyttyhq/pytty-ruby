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
            Pytty::Client::Api::Stdout.run id: id
          end
        end
      end
    end
  end
end

