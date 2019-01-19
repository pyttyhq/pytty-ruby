# frozen_string_literal: true

module Pytty
  module Daemon
    module Components
      module YieldHandler
        def self.handle(component:, id:, params:)
          process_yield = Pytty::Daemon.yields[id]
          return [404, "not found"] unless process_yield

          return case component
          when "port"
            endpoint = Async::IO::Endpoint.tcp('0.0.0.0', params["from"].to_i)
            endpoint.accept do |client|
              process_yield.spawn unless process_yield.running?
              p ["port accept", client.object_id]
              upstream = Async::IO::Endpoint.tcp('0.0.0.0', params["to"].to_i)
              peer = nil
              upstream.connect do |peer|
                Async::Task.current.async do |task|
                  while rata = peer.read(1)
                    client.write rata
                  end
                  client.close
                end

                while data = client.read(2)
                  p data
                  peer.write(data)
                end
              end
            rescue Errno::ECONNREFUSED
              sleep 0.1
              p ["port upstream retry"]
              retry
            # rescue Async::Wrapper::Cancelled
            #   # ???
            rescue Exception => ex
              p ["accex", ex]
            ensure
              peer.close
              client.close
            end

            [200, "ok"]
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
