require "io/console"

module Pytty
  module Client
    module Api
      class Attach
        def self.run(id:, interactive:)
          stdin_task = Async::Task.current.async do
            internet = Async::HTTP::Internet.new
            headers = [['accept', 'application/json']]
            body = {}.to_json

            # stdin_body = {
            #   c: '\f'
            # }.to_json
            # response = internet.post("#{Pytty::Client.host_url}/v1/stdin/#{id}", headers, [stdin_body])

            if interactive
              $stdin.raw!
              $stdin.echo = false
            end
            async_stdin = Async::IO::Stream.new(
              Async::IO::Generic.new($stdin)
            )

            detach_sequence_started = false
            while c = async_stdin.read(1) do
              detach = false
              case c
              when "\x10"
                detach_sequence_started = true
                next
              when "\x11"
                detach = true if detach_sequence_started
              when "\x03"
                detach = true unless interactive
              end

              if detach
                puts ""
                puts "detached.\r"
                exit 0
              end

              detach_sequence_started = false

              if interactive
                stdin_body = {
                  c: c
                }.to_json
                response = internet.post("#{Pytty::Client.host_url}/v1/stdin/#{id}", headers, [stdin_body])
              end
            end
          end

          begin
            internet = Async::HTTP::Internet.new
            headers = [['accept', 'application/json']]
            body = {}.to_json

            response = internet.post("#{Pytty::Client.host_url}/v1/attach/#{id}", headers, [body])
            response.body.each do |c|
              print c
            end
          rescue Async::Wrapper::Cancelled => ex
            p ["rescued", ex]
          ensure
            stdin_task.stop

            internet.close
          end
        end
      end
    end
  end
end
