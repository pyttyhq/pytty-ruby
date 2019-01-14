# frozen_string_literal: true

module Pytty
  module Client
    def self.host_url
      if ENV["PYTTY_HOST"]
        ENV["PYTTY_HOST"]
      else
        "http://localhost:1234"
      end
    end
  end
end

require_relative "client/process_yield"
require_relative "client/api"
