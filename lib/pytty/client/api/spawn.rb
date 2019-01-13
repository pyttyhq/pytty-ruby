module Pytty
  module Client
    module Api
      class Spawn
        def self.run(id:, tty:, interactive:)
          internet = Async::HTTP::Internet.new
          headers = [['accept', 'application/json']]
          body = {
            tty: tty,
            interactive: interactive
          }.to_json

          response = internet.post("http://localhost:1234/v1/spawn/#{id}", headers, [body])
          JSON.parse(response.read)
        ensure
          internet.close
        end
      end
    end
  end
end
