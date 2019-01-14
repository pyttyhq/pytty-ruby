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
      def running?
        !@pid.nil?
      end
      def to_s
        fields = []
        fields << @id
        fields << running?
        fields << @cmd.join(" ")
        fields.join("\t")
      end

      def spawn(tty:, interactive:)
        Pytty::Client::Api::Spawn.run id: @id, tty: tty, interactive: interactive
      end

      def attach(interactive:)
        Pytty::Client::Api::Attach.run id: @id, interactive: interactive
      end
    end
  end
end
