# frozen_string_literal: true

module Pytty
  module Common
    module Cli
      class VersionCommand < Clamp::Command
        def execute
          puts Pytty::VERSION
        end
      end
    end
  end
end

