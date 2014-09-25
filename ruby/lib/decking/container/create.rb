module Decking
  class Container
    def create
      Decking.run_with_progress("Creating #{name}...") do
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
                                                'Hostname'     => hostname      || "#{name}.#{group}" || "",
                                                'Domainname'   => domainname    || "",
                                                'Cmd'          => command       || "",
                                                'Entrypoint'   => entrypoint    || nil,
                                                'Memory'       => memory        || 0,
                                                'MemorySwap'   => memory_swap   || 0,
                                                'CpuShares'    => cpu_shares    || 0,
                                                'Cpuset'       => cpu_set       || "",
                                                'AttachStdout' => attach_stdout || false,
                                                'AttachStderr' => attach_stderr || false,
                                                'AttachStdin'  => attach_stdin  || false,
                                                'Tty'          => tty           || false,
                                                'OpenStdin'    => open_stdin    || false,
                                                'StdinOnce'    => stdin_once    || false,
                                                'Env'          => env.map       { |k, v| "#{k}=#{v}" },
                                                'ExposedPorts' => exposed_ports

        rescue Excon::Errors::Conflict => e
          puts "Container #{name} already exists"
        rescue Exception => e
          puts "Unhandled Exception #{e.message}"
          puts e.backtrace.inspect
        end
      end
    end
  end
end
