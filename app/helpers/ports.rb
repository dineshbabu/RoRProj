#PORTS.rb
# Helper classes for processing ports
#

class ALMports
  require 'socket'
   
  OS = RbConfig::CONFIG["host_os"]
  
  def isPortReachable(ip, port, seconds=1)
      ## Open a port, if we can't then its "free"
      require 'timeout'
      Timeout::timeout(seconds) do
        begin
          TCPSocket.new(ip, port).close
          1
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          0
        end
      end
      rescue Timeout::Error
  end
  
  def isPortOpenNonBlock(ip, port)
    # Problems with this on UNIX
    s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    sa = Socket.sockaddr_in(port, ip)
  
    begin
      s.connect_nonblock(sa)
    rescue Errno::EINPROGRESS
      if IO.select(nil, [s], nil, 1)
        begin
          s.connect_nonblock(sa)
        rescue Errno::EISCONN
            puts "EISCONN"
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            puts "ECONNREFUSED / HOSTUNREACH"
          return false
        end
      end
    end
  
    return false
  end
	
  def findFreePort(host, range_start, range_end)
		# loop through range of ports until get the first free port number
		port = Integer(range_start)
		port_end = Integer(range_end)
		
		status = false
		status_msg = "Range doesn't have a free port : " + port.to_s() + ' - ' + port_end.to_s()
		
		while (port <= port_end) 
			#puts 'port = ' + port.to_s()
			ret = isPortReachable(host, port)

            puts "RET (" + host +":"+ port.to_s() +"): " + ret.to_s()
            
			if 0 == ret
				#puts 'True, port is free - ' + port.to_s()
				status = true
				status_msg = port.to_s()
				return status, status_msg
			elsif 1 == ret
                status = false
				#puts 'False, port is in use - ' + port.to_s()
			elsif -1 == ret
                status = false
                status_msg = "Error, junk connection details? " + port.to_s()
                #puts 'Error, port bad - ' + port.to_s()
                return status, status_msg
			end
			
			port += 1
		end
		
		return status, status_msg
  end

    def testSCTAddress(port, host='localhost')
        # Open the common tools front page and scrape test to check validity.
        begin
        require 'open-uri'
        url = 'http://' + host + ":" + port.to_s()
        page = open(url).read(500)
        
        status = false
        
        found = page.scan("<title>Serena Common Tools</title>")
        
        if found.length > 0
          status = true
          status_msg = found[0]
        end

        rescue Errno::ECONNREFUSED
            status = false
        end
        
        return status
    end

end

# __FILE__ hard coded to this file
# if argv[0] is this file, I'm being run standalone
# execute the following lines:
if __FILE__ == $0
  s = ALMports.new

  port=8081
  port_end=8085
  host='localhost'
  
  ret, msg = s.findFreePort(host,port,port_end)
  puts "findFreePort(" +host+":"+port.to_s()+"-"+port_end.to_s() + "=): " + (ret ? "SUCCESS " : "FAILED ") +String(msg)

  ret = s.testSCTAddress(port)
  puts "testSCTAddress(" +port.to_s()+"): " + (ret ? "SUCCESS" : "FAILED")

  ret = s.isPortReachable(host, port)
  puts "isPortReachable(" +host+":"+port.to_s()+"): " + (ret ? "SUCCESS" : "FAILED")
  
end
  
  