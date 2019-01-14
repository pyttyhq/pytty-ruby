# frozen_string_literal: true

module Pytty
  module Daemon
    module Components
      module Handler
        def self.handle(component:, params:)
          return case component
          when "ps"
            output = []
            Pytty::Daemon.yields.each do |id, process_yield|
              output << process_yield
            end
            [200, output]
          when "yield"
            cmd = params.dig "cmd"
            env = params.dig "env"
            id = params.dig "id"

            process_yield = Pytty::Daemon::ProcessYield.new cmd, id: id, env: env
            Pytty::Daemon.yields[process_yield.id] = process_yield
            Pytty::Daemon.dump

            [200, process_yield]
          else
            raise "unknown: #{component}"
          end
        end
      end
    end
  end
end

