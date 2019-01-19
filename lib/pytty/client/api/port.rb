module Pytty
  module Client
    module Api
      class Port
        def self.run(id:, from:, to:)
          internet = Async::HTTP::Internet.new
          headers = [['accept', 'application/json']]
          body = {
            from: from,
            to: to
          }.to_json

          response = internet.post("#{Pytty::Client.host_url}/v1/port/#{id}", headers, [body])
          [response, JSON.parse(response.body.read)]
        ensure
          internet.close
        end
      end
    end
  end
end
