module Pytty
  module Client
    module Api
      class Attach
        def self.run(id:)
          Async::Task.current.async do |stdin_task|
            internet = Async::HTTP::Internet.new
            headers = [['accept', 'application/json']]
            body = {}.to_json

            $stdin.raw!
            $stdin.echo = false
            async_stdin = Async::IO::Stream.new(
              Async::IO::Generic.new($stdin)
            )

            stdin_body = {
              c: "\f"
            }.to_json
            response = internet.post("http://localhost:1234/v1/stdin/#{id}", headers, [stdin_body])

            detach_sequence_started = false
            while c = async_stdin.read(1) do
              case c
              when "\x10"
                detach_sequence_started = true
                next
              when "\x11"
                if detach_sequence_started
                  detach_sequence_started = false
                  exit 0
                end
              end

              detach_sequence_started = false

              stdin_body = {
                c: c
              }.to_json
              response = internet.post("http://localhost:1234/v1/stdin/#{id}", headers, [stdin_body])
            end
          end

          begin
            internet = Async::HTTP::Internet.new
            headers = [['accept', 'application/json']]
            body = {}.to_json

            response = internet.post("http://localhost:1234/v1/attach/#{id}", headers, [body])
            response.body.each do |c|
              print c
            end
          rescue Async::Wrapper::Cancelled => ex
          ensure
            internet.close
          end
        end
      end
    end
  end
end
