#SERVICES.rb
# Helper classes to start services
# SerenaTomcat
# Dimensions Listener
#

class ALMServices
  require 'open3'
  
  OS = RbConfig::CONFIG["host_os"]
  
  def runSysCmd(command)
    #puts command
    stdin, out, err, wait_thread = Open3.popen3(command)
    stdin.close
    child_pid = wait_thread.pid
        
    out_msg = out.readlines.join("")
    err_msg = err.readlines.join("")
    
    #puts "OUT= " + out_msg
    #puts "ERR= " + err_msg
    
    return out_msg, err_msg
  end
  
  def startWinService(service)
      if "mingw32" == OS || "mingw64" == OS
        command = "net start " + service
        
        out_msg, err_msg = runSysCmd(command)
       
        if out_msg
          found = out_msg.scan("service was started successfully.")
          if found.length > 0
            status = true
            status_msg = found[0]
          end
        end
        
        if err_msg
          found = err_msg.scan("service has already been started.")
         if found.length > 0
           status = true
           status_msg = found[0]
         end
        end
        
        return status, status_msg
      else
        return false, "Windows only, sorry"
      end
  end
  
  def stopWinService(service)
      if "mingw32" == OS || "mingw64" == OS
        command = "net stop " + service
        
        out_msg, err_msg = runSysCmd(command)
        
        if out_msg
          found = out_msg.scan("service was stopped successfully.")
          if found.length > 0
            status = true
            status_msg = found[0]
          end
        end
        if err_msg
          found = err_msg.scan("service is not started.")
          if found.length > 0
            status = true
            status_msg = found[0]
          end
        end
       
        return status, status_msg
      else
        return false, "Windows only, sorry"
      end
  end

  def statusWinService(service)
    # Returns true = status running | false = status stopped
      if "mingw32" == OS || "mingw64" == OS
        command = "sc query " + service
        
        out_msg, err_msg = runSysCmd(command)
        
        puts "OUT: " + out_msg
        puts "ERR: " + err_msg
        
        if out_msg
          found = out_msg.scan("RUNNING")
          if found.length > 0
            puts "            puts status = true"
            status = true
            status_msg = found[0]
          else
            found = out_msg.scan("STOPPED")
            if found.length > 0
              status = false
              status_msg = found[0]
			else
			  found = out_msg.scan("FAILED")
              if found.length > 0
                status = false
                status_msg = String.new("Cannot determine the service state")
			  end
            end
          end
        end
        if err_msg.length > 0
          puts "ERROR FOUND"
          status_msg = String.new("error running command")
          status = false
        end
       
        return status, status_msg
      else
        return false, "Windows only, sorry"
      end
  end
  
  # very similar to statusWinService()
  # Validates there is a windows service defined with the supplied display name
  def detectWinService(service)
    # Returns true = service exists | false = servcice does not exist
    if "mingw32" == OS || "mingw64" == OS
        command = "sc GetDisplayName " + service
        puts command
        out_msg, err_msg = runSysCmd(command)
        
        puts "OUT: " + out_msg
        puts "ERR: " + err_msg
        
        if out_msg
          found = out_msg.scan("GetServiceDisplayName SUCCESS")
          if found.length > 0
            puts "            puts status = true"
            status = true
            #status_msg = found[0]
			status_msg = "Successfully found Service - " + service
          else
            found = out_msg.scan("GetServiceDisplayName FAILED")
            if found.length > 0
              status = false
              #status_msg = found[0]
			  status_msg = "Service not found - " + service
            end
          end
        end
        if err_msg.length > 0
          puts "ERROR FOUND"
          status_msg = String.new("error running command")
          status = false
        end
       
        return status, status_msg
      else
        return false, "Windows only, sorry"
      end
  end
  
  def isrunningCMServer
    if "mingw32" == OS || "mingw64" == OS#
      service = 'Serena_Dimensions_Listener_Service'
      status, status_msg = statusWinService(service)
    else
        puts "TODO: UNIX CM start"
    end
    return status, status_msg
  end
  
  def startCMServer
    if "mingw32" == OS || "mingw64" == OS#
      service = 'Serena_Dimensions_Listener_Service'
      status, status_msg = startWinService(service)
    else
        puts "TODO: UNIX CM start"
    end
    return status, status_msg
  end
  
  def stopCMServer
    if "mingw32" == OS || "mingw64" == OS#
      service = 'Serena_Dimensions_Listener_Service'
      status, status_msg = stopWinService(service)
    else
      puts "TODO: UNIX service stop"
    end
    return status
  end
  
  def testCMListener
    if "mingw32" == OS || "mingw64" == OS#
      service = 'Serena_Dimensions_Listener_Service'
      status, status_msg = detectWinService(service)
    else
      puts "TODO: UNIX service stop"
    end
    return status, status_msg
  end
  
  def isrunningSCTomcat
    if "mingw32" == OS || "mingw64" == OS#
      service = 'SerenaTomcat'
      status, status_msg = statusWinService(service)
    else
        puts "TODO: UNIX CM start"
    end
    return status, status_msg
  end
    
  def startSCTomcat
    if "mingw32" == OS || "mingw64" == OS
      service = 'SerenaTomcat'
      status, status_msg = startWinService(service)
    else
      puts "TODO: UNIX service start"
    end
    
    return status, status_msg
  end

  def stopSCTomcat
    if "mingw32" == OS || "mingw64" == OS
      service = 'SerenaTomcat'
      status, status_msg = stopWinService(service)
    else
      puts "TODO: UNIX service start"
    end
    
    return status, status_msg
  end
end

# __FILE__ hard coded to this file
# if argv[0] is this file, I'm being run standalone
# execute the following lines:
if __FILE__ == $0
  s = ALMServices.new

  ret, msg = s.testcmlistener
  if ret
    puts "1. CM Service Exists " + String(msg)
  else
    puts "1. CM Service doesn't Exist: " + String(msg)
  end
  
  ret, msg = s.isrunningCMServer
  if ret
    puts "------------------"
    puts "0. CM RUNNING: " + String(msg) + String(ret)
  else
    puts "------------------"
    puts "0. CM STOPPED: " + String(msg) + String(ret)
  end
    
  ret, msg = s.isrunningSCTomcat
  if ret
    puts "0. TOMCAT RUNNING: " + String(msg) + String(ret)
  else
    puts "0. TOMCAT STOPPED: " + String(msg) + String(ret)
  end

  ret, msg = s.startSCTomcat
  if ret
    puts "------------------"
    puts "1. TOMCAT Success: " + String(msg)
  else
    puts "------------------"
    puts "1. TOMCAT Failed: " + String(msg)
  end
  
  ret, msg = s.isrunningSCTomcat
  if ret
    puts "1. TOMCAT RUNNING: " + String(msg)
  else
    puts "1. TOMCAT STOPPED: " + String(msg)
  end
  
  ret, msg = s.startCMServer
  if ret
    puts "1. CM Success: " + String(msg)
  else
    puts "1. CM Failed: " + String(msg)
  end

  


  ret, msg = s.isrunningCMServer
  if ret
    puts "1. CM RUNNING: " + String(msg)
  else
    puts "1. CM STOPPED: " + String(msg)
  end
  
  ret, msg = s.stopSCTomcat
  if ret
    puts "------------------"
    puts "2. TOMCAT Success: " + String(msg)
  else
    puts "------------------"
    puts "2. TOMCAT Failed: " + String(msg)
  end
  
  ret, msg = s.isrunningSCTomcat
  if ret
    puts "2. TOMCAT RUNNING: " + String(msg)
  else
    puts "2. TOMCAT STOPPED: " + String(msg)
  end
 
  ret, msg = s.stopCMServer
  if ret
    puts "2. CM Success: " + String(msg)
  else
    puts "2. CM Failed: " + String(msg)
  end
  
  ret, msg = s.isrunningCMServer
  if ret
    puts "2. CM RUNNING: " + String(msg)
  else
    puts "2. CM STOPPED: " + String(msg)
  end
end
  
  
