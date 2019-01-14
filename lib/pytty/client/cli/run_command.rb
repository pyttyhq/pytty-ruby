# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class RunCommand < Clamp::Command
        parameter "CMD ...", "command"
        option ["-i","--interactive"], :flag, "interactive"
        option ["-t","--tty"], :flag, "tty"
        option ["-d","--detach"], :flag, "detach"
        option ["--name"], "name", "name"

        def execute
          Async.run do |task|
            json = Pytty::Client::Api::Yield.run id: name, cmd: cmd_list, env: {}
            process_yield = Pytty::Client::ProcessYield.from_json json
            unless detach?
              task.async do
                process_yield.attach interactive: interactive?
              end
            end

            process_yield.spawn tty: tty?, interactive: interactive?

            if detach?
              puts process_yield.id
            end
          end
        end
      end
    end
  end
end

