module Decking
  class Container
    def attach
      $stdout.puts "Attaching to #{name}... unattach with ^C".yellow
      $stdout.flush
      begin
        Docker::Container.get(name).attach do |stream, chunk|
          case stream
          when :stdout
            $stdout.puts "(#{name}) #{stream}: #{chunk}"
          when :stderr
            $stdout.puts "(#{name}) #{stream}: #{chunk}"
          end
          $stdout.flush
        end
      rescue Docker::Error::NotFoundError
        puts "Container #{name} does not exist, nothing to attach to".yellow
      rescue Docker::Error::ServerError => e
        puts e.message.red
      end
    end
  end
end
