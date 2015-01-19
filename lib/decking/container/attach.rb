module Decking
  class Container
    @@logger = Log4r::Logger.new('decking::container::attach')
    def tail_logs
      @@logger.info "Grabbing logs from #{name}... stop with ^C".yellow
      begin
        Docker::Container.get(name).streaming_logs(follow: true, stdout: true, stderr: true, tail: 100, timestamps: false) do |stream, chunk|
          case stream
            when :stdout
              $stdout.print "(#{name}) #{chunk}"
              $stdout.flush
            when :stderr
              $stdout.print "(#{name}) #{chunk}".red
              $stdout.flush
          end
        end
      end
    end
  end
end
