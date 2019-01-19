module Pytty
  module Client
    module Api
      class Stderr
        def self.run(id:)
          internet = Async::HTTP::Internet.new
          headers = [['accept', 'application/json']]
          body = {
          }.to_json

          response = internet.post("#{Pytty::Client.host_url}/v1/stderr/#{id}", headers, [body])
          [response, response.body]
        ensure
          internet.close
        end
      end
    end
  end
end
