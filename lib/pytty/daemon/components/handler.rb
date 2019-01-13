# frozen_string_literal: true
require "rack/request"
require "mustermann"

module Pytty
  module Daemon
    module Components
      module Handler
        def self.handle(component:, id:, params:)
          return case component
          when "signal"
            process_yield = Pytty::Daemon.yields[id]
            return [404, "not found"] unless process_yield
            return [500, "not running"] unless process_yield.running?
            p params
            process_yield.signal params["signal"]
            [200, "ok"]
          when "spawn"
            process_yield = Pytty::Daemon.yields[id]
            return [404, "not found"] unless process_yield

            process_yield.spawn
            Pytty::Daemon.dump

            [200, "ok"]
          when "ps"
            output = []
            Pytty::Daemon.yields.each do |id, process_yield|
              output << process_yield
            end
            [200, output]
          when "yield"
            cmd = params.dig "cmd"
            env = params.dig "env"
            process_yield = Pytty::Daemon::ProcessYield.new cmd, env: env
            Pytty::Daemon.yields[process_yield.id] = process_yield
            Pytty::Daemon.dump

            [200, process_yield]
          when "rm"
            process_yield = Pytty::Daemon.yields[id]
            p Pytty::Daemon.yields
            p id
            return [404, "not found"] unless process_yield
            if process_yield.running?
              process_yield.kill
            end
            Pytty::Daemon.yields.delete process_yield.id
            Pytty::Daemon.dump

            [200, nil]
          when "spawn"
            process_yield = Pytty::Daemon.yields[id]
            return [404, "not found"] unless process_yield

            pipe = IO.pipe
            stderr_reader = Async::IO::Generic.new(pipe.first)
            stderr_writer = Async::IO::Generic.new(pipe.last)

            process_yield.spawn stdout: $stdout, stderr: stderr_writer, stdin: $stdin
            stderr_reader.close
            [200, process_yield]
          else
            raise "unknown: #{component}"
          end
        end
      end
    end
  end
end

