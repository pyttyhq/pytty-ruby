# frozen_string_literal: true
require "securerandom"
require "pty"

module Pytty
  module Daemon
    class ProcessYield
      def initialize(cmd, id:nil, env:{})
        @cmd = cmd
        @env = env

        @pid = nil
        @status = nil
        @id = id || SecureRandom.uuid

        @stdout = nil
        @stdouts = {}
        @stdin = Async::Queue.new
      end

      attr_reader :id, :cmd, :pid, :status, :stdout
      attr_accessor :stdin

      def add_stdout(stdout)
        notification = Async::Notification.new
        @stdouts[notification] = stdout
        notification
      end

      def running?
        !@pid.nil?
      end

      def to_json(json_generator_state=nil)
        {
          id: @id,
          pid: @pid,
          status: @status,
          cmd: @cmd,
          env: @env,
          running: running?
        }.to_json
      end

      def spawn
        return false if running?
        @status = nil

        executable, args = @cmd
        # @env.merge!({
        #   "TERM" => "xterm"
        # })

        stdout_path = File.join(Pytty::Daemon.pytty_path, @id)
        File.unlink stdout_path if File.exist? stdout_path
        stdout_appender = Async::IO::Stream.new(
          File.open stdout_path, "a"
        )
        @stdout = Async::IO::Stream.new(
          File.open stdout_path, "r"
        )
        Async::Task.current.async do |task|
          real_stdout, real_stdin, pid = PTY.spawn @env, executable, *args
          @pid = pid
          async_stdout = Async::IO::Generic.new real_stdout
          async_stdin = Async::IO::Generic.new real_stdin

          task_stdin_writer = task.async do |subtask|
            while c = @stdin.dequeue do
              async_stdin.write c
            end
          rescue Async::Stop => ex
          rescue Exception => ex
            puts "async_stdin.write: #{ex.inspect}"
          end

          task_stdout_writer = task.async do |subtask|
            while c = async_stdout.read(1)
              stdout_appender.write c
              stdout_appender.flush

              @stdouts.each do |notification, stdout|
                begin
                  stdout.write c
                rescue Errno::EPIPE, Errno::EPROTOTYPE => ex
                  notification.signal
                  @stdouts.delete notification
                end
              end
            end
          rescue Async::Stop
            signal "kill"
          rescue Exception => ex
            p ["async_stdout.read", ex]
          ensure
            task_stdin_writer.stop
            Process.wait(@pid)
            @status = if $?.exitstatus
              $?.exitstatus
            else
              Signal.signame $?.termsig
            end
            puts "exited #{@id} with status: #{@status}"

            @pid = nil
            stdout_appender.close

            @stdouts.each do |notification, stdout|
              notification.signal
              @stdouts.delete notification
            end
            Pytty::Daemon.dump
          end
        end.wait

        puts "spawned #{id}"
        return true
      end

      def signal(sig)
        return unless @pid
        Process.kill(sig.upcase, @pid)
      end
    end
  end
end

