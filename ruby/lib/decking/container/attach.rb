module Decking
  class Container
    def attach
      begin
        Decking.clear_progressline
        Docker::Container.get(name).attach do |stream, chunk|
          $stdout.puts "#{stream}: #{chunk}"
          $stdout.flush
        end
      rescue Docker::Error::NotFoundError
        Decking.clear_progressline
        puts "Container #{name} does not exist, nothing to attach to".yellow
      rescue Docker::Error::ServerError => e
        Decking.clear_progressline
        puts e.message.red
      end
    end
  end
end

