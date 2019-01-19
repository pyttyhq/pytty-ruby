# frozen_string_literal: true

module Pytty
  module Client
    module Cli
      class StatusCommand < Clamp::Command
        parameter "ID ...", "id"

        def execute
          Async.run do
            for id in id_list do
              response, body = Pytty::Client::Api::Status.run id: id
              if response.status == 200
                puts body
              else
                puts body
                exit 1
              end
            end
          end
        end
      end
    end
  end
end

