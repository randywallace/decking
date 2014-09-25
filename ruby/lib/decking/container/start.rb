module Decking
  class Container
    def start
      Decking.run_with_progress("Starting #{name}...") do
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
        rescue Docker::Error::ServerError => e
          puts e.message
        rescue Exception => e
          puts "Unhandled Exception #{e.message}"
          puts e.backtrace.inspect
        end
      end
    end
  end
end
