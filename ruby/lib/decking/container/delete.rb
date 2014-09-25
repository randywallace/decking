
module Decking
  class Container
    def delete force = false
      Decking.run_with_progress("#{'Forcefully ' if force}Deleting #{name}") do
        begin
            Docker::Container.get(name).remove('force' => force)
        rescue Docker::Error::NotFoundError
          Decking.clear_progressline
          puts "Container #{name} does not exist, nothing to delete".yellow
        end
      end
    end

    def delete!
      delete true
    end
  end
end
