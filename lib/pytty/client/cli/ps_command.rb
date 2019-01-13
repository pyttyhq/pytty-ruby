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
          process_yields = Async.run do
            Pytty::Client::Api::Ps.run
          end.wait

          unless quiet?
            puts "id  cmd"
            puts "-"*40
          end
          for process_yield in process_yields do
            if quiet?
              puts process_yield.fetch "id"
            else
              puts process_yield
            end
          end
        end
      end
    end
  end
end

