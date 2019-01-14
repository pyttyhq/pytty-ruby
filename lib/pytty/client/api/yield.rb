module Pytty
  module Client
    module Api
      class Yield
        def self.run(cmd:, id:, env:)
          internet = Async::HTTP::Internet.new
          headers = [['accept', 'application/json']]

          term_env = {
            "LINES" => IO.console.winsize.first.to_s,
            "COLUMNS" => IO.console.winsize.last.to_s
          }.merge env

          body = {
            id: id,
            cmd: cmd,
            env: term_env
          }.to_json

          response = internet.post("#{Pytty::Client.host_url}/v1/yield", headers, [body])
          JSON.parse(response.body.read)
        end
      end
    end
  end
end