# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class YieldCommand < Clamp::Command
        parameter "CMD ...", "command"
        option ["--name"], "NAME", "name"

        def execute
          response, json = Async.run do
            Pytty::Client::Api::Yield.run cmd: cmd_list, id: name, env: {}
          end.wait

          if response.status == 200
            process_yield = ::Pytty::Client::ProcessYield.from_json json
            puts process_yield.id
          else
            puts json
          end

        end
      end
    end
  end
end

