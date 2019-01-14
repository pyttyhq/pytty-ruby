# frozen_string_literal: true
require 'async'
require 'async/http'
require 'async/http/internet'
require 'json'

module Pytty
  module Client
    module Cli
      class SpawnCommand < Clamp::Command
        parameter "ID ...", "id"

        def execute
          Async.run do
            for id in id_list
              response, body = Pytty::Client::Api::Spawn.run id: id, tty:true, interactive:true
              unless response.status == 200
                puts body
                exit 1
              else
                puts id
              end
            end
          end
        end
      end
    end
  end
end

