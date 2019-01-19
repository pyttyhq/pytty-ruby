# frozen_string_literal: true
require "securerandom"
require "pty"
require "open3"

module Pytty
  module Daemon
    class ProcessYield
      def initialize(cmd, id:nil, env:{})
        @cmd = cmd
        @env = env

        @pid = nil
        @status = nil
        @id = id || SecureRandom.uuid

        @stdouts = {}
        @stderrs = {}

        @stdout_path = File.join Pytty::Daemon.pytty_path, "#{@id}.stdout"
        @stderr_path = File.join Pytty::Daemon.pytty_path, "#{@id}.stderr"

        @stdin = Async::Queue.new
      end

      attr_reader :id, :cmd, :pid, :status
      attr_reader :stdout_path, :stderr_path
      attr_accessor :stdin

      def add_stdout(stdout)
        notification = Async::Notification.new
        @stdouts[notification] = stdout
        notification
      end
      def add_stderr(stderr)
        notification = Async::Notification.new
        @stderrs[notification] = stderr
        notification
      end

      def running?
        # test by killing?
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

      def cleanup
        @status = nil

        File.unlink @stdout_path if File.exist? @stdout_path
        File.unlink @stderr_path if File.exist? @stderr_path
      end

      def spawn(tty: false, interactive: false)
        return false if running?
        cleanup

        stdout_appender = Async::IO::Stream.new(
          File.open @stdout_path, "a"
        )
        stderr_appender = Async::IO::Stream.new(
          File.open @stderr_path, "a"
        )

        executable, *args = @cmd
        # @env.merge!({
        #   "TERM" => "xterm"
        # })

        Async::Task.current.async do |task|
          real_stdout, real_stdin, real_stderr, @pid, wait_thr  = begin
            if tty
              stderr_reader, stderr_writer = IO.pipe
              p ["spawn", "PTY"]
              #TODO: if bash is started, no prompt is written in stderr or stdout
              p_stdout, p_stdin, pid = PTY.spawn @env, executable, *args, err: stderr_writer

              [p_stdout, p_stdin, stderr_reader, pid]
            else
              p_stdin, p_stdout, p_stderr, p_wait_thr = Open3.popen3 @env, executable, *args, {}
              [p_stdout, p_stdin, p_stderr, p_wait_thr.pid, p_wait_thr]
            end
          rescue Errno::ENOENT => ex
            raise unless ex.message == "No such file or directory - #{executable}"
          end

          next unless @pid  #command failed to spawn

          async_stdout = Async::IO::Generic.new real_stdout
          async_stdin = Async::IO::Generic.new real_stdin
          async_stderr = Async::IO::Generic.new real_stderr

          task_stdin_writer = if interactive
            task.async do |subtask|
              p ["task_stdin_writer", "started"]
              while c = @stdin.dequeue do
                async_stdin.write c
              end
            rescue Async::Stop => ex
              puts "async_stdin#write Async::Stop"
            rescue Exception => ex
              puts "async_stdin#write: #{ex.inspect}"
            ensure
              async_stdin.close
              p ["async_stdin", "closed"]
            end
          else
            nil
          end

          task_stderr_writer = task.async do
            p ["task_stderr_writer", "started"]
            while c = async_stderr.read(1) do
              stderr_appender.write c
              stderr_appender.flush

              @stderrs.each do |notification, stderr|
                begin
                  stderr.write "2#{c}"
                rescue Async::HTTP::Body::Writable::Closed
                  puts "signaling error"
                  notification.signal
                  @stderrs.delete notification
                rescue => ex
                  raise ex
                end
              end
            end
            p ["task_stderr_writer", "async_stderr has no more read"]
          rescue Exception => ex
            p ["async_stderr ex:", ex]
          ensure
            stderr_appender.flush
            stderr_appender.close
            puts "stderr_appender closed"
            async_stderr.close
            puts "async_stderr closed"
          end

          task_stdout_writer = task.async do
            p ["task_stdout_writer", "started"]

            while c = async_stdout.read(1)
              stdout_appender.write c
              stdout_appender.flush

              @stdouts.each do |notification, stdout|
                begin
                  stdout.write "1#{c}"
                rescue Errno::EPIPE, Errno::EPROTOTYPE => ex
                  notification.signal
                  @stdouts.delete notification
                end
              end
            end
            p ["task_stdout_writer", "stopped"]
          rescue Async::Stop
            signal "kill"
          rescue Exception => ex
            p ["async_stdout", ex]
          ensure
            process_status = if wait_thr
              wait_thr.value
            else
              begin
                Process.wait(@pid)
                $?
              rescue Errno::ECHILD => ex
                raise ex unless ex.message == "No child processes"
                puts "NO CHILD PROCESS"
                nil
              end
            end

            @status = if process_status && process_status.exitstatus
              process_status.exitstatus
            else
              Signal.signame process_status.termsig
            end

            puts "exited #{@id} with status: #{@status}"
            @pid = nil
            task_stdin_writer.stop if task_stdin_writer

            @stdouts.each do |notification, stdout|
              notification.signal
              @stdouts.delete notification
            end
            @stderrs.each do |notification, stderr|
              notification.signal
              @stdouts.delete notification
            end
            Pytty::Daemon.dump
          end
        end

        if @pid
          p ["spawned", id]
          return true
        else
          p ["failed to spawn"]
          @status = 127
          return false
        end
      end

      def signal(sig)
        return unless @pid
        Process.kill(sig.upcase, @pid)
      rescue Errno::ESRCH => ex
        raise ex unless ex.message == "No such process"
      end
    end
  end
end
