module Pytty
  module Client
    module Api
      class Ps
        def self.run
          internet = Async::HTTP::Internet.new
          headers = [['accept', 'application/json']]
          body = {}.to_json

          response = internet.post("#{Pytty::Client.host_url}/v1/ps", headers, [body])
          JSON.parse(response.body.read)
        ensure
          internet.close
        end
      end
    end
  end
end
