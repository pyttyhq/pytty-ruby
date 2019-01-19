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
            response, body = Pytty::Client::Api::Yield.run id: name, cmd: cmd_list, env: {}
            unless response.status == 200
              puts body
              exit 1
            end
            process_yield = Pytty::Client::ProcessYield.from_json body

            attach_task = unless detach?
              task.async do
                process_yield.attach interactive: interactive?
              end
            end

            response, body = process_yield.spawn tty: tty?, interactive: interactive?
            if response.status == 200
              if detach?
                puts process_yield.id
              end
            else
              puts body
              attach_task.stop
              print "\r" unless detach?
            end
          end
        end
      end
    end
  end
end

