module Decking
  class Container
    def create force = false
      run_with_progress("#{"Forcefully " if force}Creating #{name}") do
        begin
          exposed_ports = Hash.new
          port.each do |val|
            vars = val.split(':')
            if vars.size == 3
              exposed_ports[vars[-2]] = Hash.new
            else
              exposed_ports[vars[-1]] = Hash.new
            end
          end
          @container = Docker::Container.create 'name'         => name,
                                                'Image'        => image,
                                                'Hostname'     => hostname,
                                                'Domainname'   => domainname,
                                                'Entrypoint'   => entrypoint,
                                                'Memory'       => memory,
                                                'MemorySwap'   => memory_swap,
                                                'CpuShares'    => cpu_shares,
                                                'Cpuset'       => cpu_set,
                                                'AttachStdout' => attach_stdout,
                                                'AttachStderr' => attach_stderr,
                                                'AttachStdin'  => attach_stdin,
                                                'Tty'          => tty,
                                                'OpenStdin'    => open_stdin,
                                                'StdinOnce'    => stdin_once,
                                                'Cmd'          => command.scan(/(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|[^'" ])+/).map{|val| val.gsub(/^['"]/,"").gsub(/['"]$/,"")},
                                                'Env'          => env.map { |k, v| "#{k}=#{v}" },
                                                'ExposedPorts' => exposed_ports
        rescue Excon::Errors::Conflict
          clear_progressline
          puts "Container #{name} already exists".yellow
          if force
            delete!
            retry
          else
            exit
          end
        rescue Docker::Error::NotFoundError
          clear_progressline
          puts "Container #{name} not found".yellow
          exit
        rescue Docker::Error::ServerError => e
          clear_progressline
          puts "Container #{name} encountered a ServerError".red
          puts e.message.red
          exit
        rescue Exception => e
          clear_progressline
          puts "Unhandled Exception #{e.message}"
          e.backtrace.map{|msg| puts "  #{msg}"}
          exit
        end
      end
    end

    def create!
      create true
    end
  end
end
