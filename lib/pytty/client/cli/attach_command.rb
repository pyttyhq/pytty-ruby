# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class AttachCommand < Clamp::Command
        parameter "ID", "id"
        option ["-i","--interactive"], :flag, "interactive"

        def execute
          Async.run do
            Pytty::Client::Api::Attach.run id: id, interactive: interactive?
          end
        end
      end
    end
  end
end

