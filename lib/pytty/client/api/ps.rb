module Pytty
  module Client
    module Api
      class Ps
        def self.run
          internet = Async::HTTP::Internet.new
          headers = [['accept', 'application/json']]
          body = {}.to_json

          response = internet.post("http://localhost:1234/v1/ps", headers, [body])
          JSON.parse(response.body.read)
        ensure
          internet.close
        end
      end
    end
  end
end
