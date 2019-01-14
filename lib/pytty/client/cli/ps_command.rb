# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class PsCommand < Clamp::Command
        option ["-q","--quiet"], :flag, "quiet"

        def execute
          process_yield_jsons = Async.run do
            Pytty::Client::Api::Ps.run
          end.wait

          unless quiet?
            puts "id\trunning\tcmd"
            puts "-"*40
          end
          for process_yield_json in process_yield_jsons do
            process_yield = Pytty::Client::ProcessYield.from_json process_yield_json
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
end

