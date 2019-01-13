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
        option ["-q", "--quiet"], :flag, "quiet"

        def execute
          process_yield = Async.run do
            json = Pytty::Client::Api::Yield.run cmd: cmd_list, env: {}
            ::Pytty::Client::ProcessYield.from_json json
          end.wait

          if quiet?
            puts process_yield.id
          else
            puts process_yield
          end
        end
      end
    end
  end
end

