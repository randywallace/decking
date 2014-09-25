
module Decking
  class Container
    def delete force = false
      run_with_progress("#{'Forcefully ' if force}Deleting #{name}") do
        begin
          Docker::Container.get(name).remove('force' => force)
        rescue Docker::Error::NotFoundError
          clear_progressline
          puts "Container #{name} does not exist, nothing to delete".yellow
        rescue Docker::Error::ServerError => e
          clear_progressline
          puts e.message.red
        end
      end
    end

    def delete!
      delete true
    end
  end
end
