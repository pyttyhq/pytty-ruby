module Pytty
  module Client
    class ProcessYield
      def initialize(id:, cmd:, env:, pid:)
        @cmd = cmd
        @env = env
        @pid = pid
        @id = id
      end

      attr_reader :id

      def self.from_json(json)
        self.new({
          id: json.fetch("id"),
          cmd: json.fetch("cmd"),
          env: json.fetch("env"),
          pid: json.fetch("pid")
        })
      end

      def to_s
        "#{@id} #{@cmd}"
      end

      def spawn(tty:, interactive:)
        Pytty::Client::Api::Spawn.run id: @id, tty: tty, interactive: interactive
      end

      def attach
        Pytty::Client::Api::Attach.run id: @id
      end
    end
  end
end
