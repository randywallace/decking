
module Decking
  class Container
    def stop time_to_kill = 30
      Decking.run_with_progress("Stopping #{name}") do
        begin
          Docker::Container.get(name).stop('t' => time_to_kill)
        rescue Docker::Error::NotFoundError
          Decking.clear_progressline
          puts "Container #{name} does not exist, nothing to stop".yellow
        end
      end
    end

    def stop!
      stop 1      
    end
  end
end

