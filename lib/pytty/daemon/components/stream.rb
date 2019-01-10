# frozen_string_literal: true
require 'pty'
require 'io/console'

module Pytty
  module Daemon
    module Components
      class Stream
        def initialize(cmd:, env:)
          @cmd = cmd
          @env = env
        end

        def run(stream:)
          pipe = IO.pipe
          stderr = Async::IO::Generic.new(pipe.first)
          stderr_writer = Async::IO::Generic.new(pipe.last)


          cmd, args = @cmd
          process_stdout, process_stdin, pid = PTY.spawn(@env, cmd, *args, err: stderr_writer.fileno)
          stderr_writer.close

          stdout = Async::IO::Generic.new process_stdout
          stdin = Async::IO::Generic.new process_stdin
          Async::Task.current.async do |task|
            while c = stdout.read(1)
              stream.write c
            end
            stream.close
          end
        end
      end
    end
  end
end

