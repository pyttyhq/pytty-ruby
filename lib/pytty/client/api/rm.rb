module Pytty
  module Client
    module Api
      class Rm
        def self.run(id:)
          internet = Async::HTTP::Internet.new
          headers = [['accept', 'application/json']]
          body = {}.to_json

          response = internet.post("#{Pytty::Client.host_url}/v1/rm/#{id}", headers, [body])
          [response, JSON.parse(response.body.read)]
        ensure
          internet.close
        end
      end
    end
  end
end
