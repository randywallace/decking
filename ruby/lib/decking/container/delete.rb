
module Decking
  class Container
    def delete force = false
      puts "Deleting #{name}..."
      begin
        Docker::Container.get(name).remove('force' => force)
      rescue Docker::Error::NotFoundError => e
        puts "Container #{name} does not exist, nothing to delete"
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end

    def delete!
      delete true
    end
  end
end
