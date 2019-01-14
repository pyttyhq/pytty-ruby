module Pytty
  module Client
    module Api
      class Signal
        def self.run(id:, signal:)
          internet = Async::HTTP::Internet.new
          headers = [['accept', 'application/json']]
          body = {
            signal: signal
          }.to_json

          response = internet.post("#{Pytty::Client.host_url}/v1/signal/#{id}", headers, [body])
          [response, JSON.parse(response.read)]
        ensure
          internet.close
        end
      end
    end
  end
end
