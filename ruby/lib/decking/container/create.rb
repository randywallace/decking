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
