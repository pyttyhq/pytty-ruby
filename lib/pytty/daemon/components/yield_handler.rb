# frozen_string_literal: true

module Pytty
  module Daemon
    module Components
      module YieldHandler
        def self.handle(component:, id:, params:)
          process_yield = Pytty::Daemon.yields[id]
          return [404, "not found"] unless process_yield

          return case component
          when "stdin"
            process_yield.stdin.enqueue params["c"]

            [200, "ok"]
          when "status"
            return [500, "still running"] if process_yield.running?

            [200, process_yield.status]
          when "signal"
            return [500, "not running"] unless process_yield.running?

            process_yield.signal params["signal"]

            [200, "ok"]
          when "spawn"
            return [500, "already running"] if process_yield.running?
            if process_yield.spawn tty: params["tty"], interactive: params["interactive"]
              Pytty::Daemon.dump
            else
              return [500, "could not spawn"]
            end

            [200, "ok"]
          when "rm"
            process_yield.signal("KILL") if process_yield.running?
            process_yield.cleanup

            Pytty::Daemon.yields.delete process_yield.id
            Pytty::Daemon.dump

            [200, id]
          else
            raise "unknown: #{component} with id: #{id}"
          end
        end
      end
    end
  end
end

