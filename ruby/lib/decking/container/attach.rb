module Decking
  class Container
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
