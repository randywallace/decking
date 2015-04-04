module Decking
  class Container
    @@logger = Log4r::Logger.new('decking::container::attach')
    def tail_logs timestamps = false, lines = 0, follow = true
      @@logger.info "Grabbing logs from #{name}... stop with ^C".yellow
      begin
        Docker::Container.get(name).streaming_logs(follow: follow, stdout: true, stderr: true, tail: lines, timestamps: timestamps) do |stream, chunk|
          case stream
            when :stdout
              $stdout.print "(#{name}) #{chunk}"
              $stdout.flush
            when :stderr
              $stdout.print "(#{name}) #{chunk}".red
              $stdout.flush
          end
        end
      rescue Docker::Error::NotFoundError
        @@logger.error "Container #{name} does not exist"
      end
    end
  end
end
