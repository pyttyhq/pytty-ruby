# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class SignalCommand < Clamp::Command
        parameter "SIGNAL", "signal"
        parameter "ID ...", "id"

        def execute
          Async.run do
            for id in id_list do
              response, body = Pytty::Client::Api::Signal.run id: id, signal: signal
              if response.status == 200
                puts id
              else
                puts body
              end
            end
          end
        end
      end
    end
  end
end

