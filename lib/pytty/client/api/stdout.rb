module Pytty
  module Client
    module Api
      class Stdout
        def self.run(id:)
          internet = Async::HTTP::Internet.new
          headers = [['accept', 'application/json']]
          body = {
          }.to_json

          response = internet.post("#{Pytty::Client.host_url}/v1/stdout/#{id}", headers, [body])
          puts response.read
        ensure
          internet.close
        end
      end
    end
  end
end
