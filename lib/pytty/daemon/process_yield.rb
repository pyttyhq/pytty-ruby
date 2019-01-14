# frozen_string_literal: true
require "securerandom"

module Pytty
  module Daemon
    class ProcessYield
      def initialize(cmd, id:nil, env:{})
        @cmd = cmd
        @env = env

        @pid = nil
        @id = id || SecureRandom.uuid

        @stdouts = []
        @stdin = Async::Queue.new
      end

      attr_reader :id, :cmd, :pid
      attr_accessor :stdouts, :stdin

      def running?
        !@pid.nil?
      end

      def to_json(json_generator_state=nil)
        {
          id: @id,
          pid: @pid,
          cmd: @cmd,
          env: @env,
          running: running?
        }.to_json
      end

      def spawn
        executable, args = @cmd
        @env.merge!({
          "TERM" => "vt100"
        })

        Async::Task.current.async do |task|
          p ["spawn", executable, args, @env]

          real_stdout, real_stdin, pid = PTY.spawn @env, executable, *args
          @pid = pid
          async_stdout = Async::IO::Generic.new real_stdout
          async_stdin = Async::IO::Generic.new real_stdin

          task_stdin_writer = task.async do |subtask|
            while c = @stdin.dequeue do
              async_stdin.write c
            end
          end

          task_stdout_writer = task.async do |subtask|
            while c = async_stdout.read(1)
              @stdouts.each do |s|
                begin
                  s.write c
                rescue Errno::EPIPE => ex
                  puts "cannnot write, popping"
                  @stdouts.pop
                end
              end
            end
          end
        end.wait

        puts "spawned"
      end

      def signal(sig)
        Process.kill(sig, @pid)
      end

      def tstp
        Process.kill("TSTP", @pid)
      end

      def cont
        Process.kill("CONT", @pid)
      end

      def kill
        Process.kill("KILL", @pid)
      end

      def term
        Process.kill("TERM", @pid)
      end
    end
  end
end

