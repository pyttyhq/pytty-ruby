# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class PortCommand < Clamp::Command
        parameter "ID", "id"
        parameter "PORTS", "ports"

        def execute
          Async.run do
            from,to = ports.split(":")
            Pytty::Client::Api::Port.run id: id, from: from, to: to
          end
        end
      end
    end
  end
end

