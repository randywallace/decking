module Decking
  class Container
    def tail_logs
      $stdout.puts "Grabbing logs from #{name}... stop with ^C".yellow
      begin
        Docker::Container.get(name).streaming_logs(follow: true, stdout: true, stderr: true, tail: 100, timestamps: true) do |stream, chunk|
          case stream
            when :stdout
              $stdout.puts "(#{name})" + " #{chunk}"
              $stdout.flush
            when :stderr
              $stdout.puts "(#{name})".red + " #{chunk}"
              $stdout.flush
          end
        end
      end
    end

    def attach
      $stdout.puts "Attaching to #{name}... unattach with ^C".yellow
      begin
        Docker::Container.get(name).attach do |stream, chunk|
          case stream
          when :stdout
            $stdout.puts "(#{name})" + " #{chunk}"
            $stdout.flush
          when :stderr
            $stdout.puts "(#{name})".red + " #{chunk}"
            $stdout.flush
          end
        end
      rescue Docker::Error::NotFoundError
        puts "Container #{name} does not exist, nothing to attach to".yellow
      rescue Docker::Error::ServerError => e
        puts e.message.red
      end
    end
  end
end
