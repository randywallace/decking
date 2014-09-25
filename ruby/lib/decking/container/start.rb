module Decking
  class Container
    def start
      Decking.run_with_progress("Starting #{name}") do
        begin
          port_bindings = Hash.new
          port.each do |val|
            vars = val.split(':')
            case vars.size
            when 3
              port_bindings[vars[-1]] = [ { 'HostIp' => vars[0], 'HostPort' => vars[1] } ]
            when 2
              port_bindings[vars[-1]] = [ { 'HostIp' => '',      'HostPort' => vars[0] } ]
            else
              port_bindings[vars[0]]  = [ { 'HostPort' => vars[0] } ]
            end
          end
          @container.start! 'Links'        => links,
                            'Binds'        => binds, 
                            'LxcConf'      => lxc_conf,
                            'PortBindings' => port_bindings
        rescue Docker::Error::NotFoundError
          Docker.clear_progressline
          puts "Container #{name} not found".red
          exit
        rescue Docker::Error::ServerError => e
          Docker.clear_progressline
          puts "Container #{name} encountered a ServerError".red
          puts e.message.red
          exit
        rescue Exception => e
          Docker.clear_progressline
          puts "Unhandled Exception #{e.message}"
          e.backtrace.map{|msg| puts "  #{msg}"}
          exit
        end
      end
    end
  end
end