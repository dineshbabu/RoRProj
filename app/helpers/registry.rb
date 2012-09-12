# REGISTRY.rb
#
# Code to supply the root folder for CM and ALM
# Cross platform support added (in CM case).
#
#
#

class GetRoots

	attr_accessor :dm_root
	OS = RbConfig::CONFIG["host_os"]

	# Create the object
	def initialize(dm_root = "no-value")
		@dm_root = dm_root
	end

	def getRegString(path, key)
		value =""
		# Platform specific code - we cant read the registry on non windows machines
		 if "mingw32" == OS || "mingw64" == OS
			require 'win32/registry'
			
			read = Win32::Registry::KEY_READ
		
			begin
				# Read the 12.2.0 registry break
				# Poor code, will improve later
				Win32::Registry::HKEY_LOCAL_MACHINE.open(path, read) do |reg|;
					value = reg[key]
					break
				end
			rescue Exception => msg
				value = String(msg.message)
			end
			
		 end
		 return value		 
	end
	
	def getCMRoot
		# Platform specific code - we cant read the registry on non windows machines
		 if "mingw32" == OS || "mingw64" == OS
			return getRegString("SOFTWARE\\Serena\\Dimensions\\12.2.0", "DM_ROOT")
		 else
			dm_root = "/opt/serena/dimensions/12.2/cm/"
			return dm_root	
		 end
	end
	
	def getALMRoot
		# Platform specific code - we cant read the registry on non windows machines
		if "mingw32" == OS || "mingw64" == OS
			return getRegString("SOFTWARE\\Serena\\Solutions\\Serena ALM", "SolutionsPath")
		else
			return "n/a"
		end
	end
	
	def getSCTRoot
	# Load pathname
	# The SCT registry entry is more than a path:
	# ""C:\Program Files (x86)\Serena\Dimensions 12.2\CM\..\Common Tools\tomcat\6.0\bin\tomcat6.exe" //RS//SerenaTomcat"
	# we need to strip the crap away.
	
		sct_root=""
		
		# Platform specific code - we cant read the registry on non windows machines
		if "mingw32" == OS || "mingw64" == OS
			require 'pathname'

			sct_root= getRegString("SYSTEM\\CurrentControlSet\\Services\\SerenaTomcat", "ImagePath")
			
			sct_root["bin\\tomcat6.exe\" //RS//SerenaTomcat"] = ''
		else
			sct_root= "/opt/serena/dimensions/12.2/common/tomcat/6.0/"
		end
		
		return sct_root
	end
	
	def testCMHome(dmroot)
	  dmroot = dmroot + "dm.cfg"
	  
	  if File.exist?(dmroot)
	    status = true
	    status_msg = "file found - " + dmroot
	  else
		status = false
		status_msg = "file not found - " + dmroot
      end
	  return status, status_msg

	end
	
	def testALMHome(almroot)
	  if File.exist?(almroot)
	    status = true
	    status_msg = "file found - " + almroot
	  else
		status = false
		status_msg = "file not found - " + almroot
          end
	  return status, status_msg

	end
	
	def testSCTHome(tomcatroot)
        # find /opt/serena/dimensions/12.2/common/tomcat/6.0/conf/server.xml:
        #       <Server port="8405" shutdown="Shutdown.SerenaCommonTomcat">
        
        require 'libxml'
        
        serverFile = tomcatroot + "conf/server.xml"
        verified = false
        status_msg = "invalid home"
        
		if File.exist?(serverFile)
            parser = LibXML::XML::Parser.file(serverFile)
            doc = parser.parse
            entries = doc.find('//Server')
            entries.each do |node|
                value = node["shutdown"]
                isCommon = value.scan("SerenaCommonTomcat")
                if isCommon.length > 0
                    verified = true
                    status_msg = "valid home"
                end
            end 
		end
		return verified, status_msg
	end
end

# __FILE__ hard coded to this file
# if argv[0] is this file, I'm being run standalone
# execute the following lines:
if __FILE__ == $0
	dmr = GetRoots.new
	puts "dmr.getCMRoot => " + dmr.getCMRoot
	puts "dmr.getALMRoot => " + dmr.getALMRoot
	puts "dmr.getSCTRoot => " + dmr.getSCTRoot
	
	path = dmr.getSCTRoot
	result = dmr.testSCTHome(path)
	puts "Test SCT: " + path
	puts "   result: " + (result ? "TRUE" : "FALSE")
	
	OS = RbConfig::CONFIG["host_os"]
	puts "Performing platform specific tests.."
	
	if "mingw32" == OS || "mingw64" == OS
		dm_root = dmr.getRegString("SOFTWARE\\Serena\\Dimensions\\12.2.0", "DM_ROOT")
		puts "getRegString DM_ROOT => " + dm_root
		
		alm_root = dmr.getRegString("SOFTWARE\\Serena\\Solutions\\Serena ALM", "SolutionsPath")
		puts "getRegString ALM_ROOT => " + alm_root
		
		sct_root = dmr.getRegString("SYSTEM\\CurrentControlSet\\Services\\SerenaTomcat", "ImagePath")
		puts "getRegString SCT_ROOT => " + sct_root
	
		puts "***********Running Tests**********"
		def runTest(res1, res2)
			puts res1 + " == " + res2
			result = "FAILED!"
			if (res1 == res2)
				result = "	PASSED"
			end
			puts result
		end
	
		runTest(dmr.getCMRoot, dmr.getRegString("SOFTWARE\\Serena\\Dimensions\\12.2.0", "DM_ROOT"))
		runTest(dmr.getALMRoot, dmr.getRegString("SOFTWARE\\Serena\\Solutions\\Serena ALM", "SolutionsPath"))
		runTest(dmr.getSCTRoot, dmr.getRegString("SYSTEM\\CurrentControlSet\\Services\\SerenaTomcat", "ImagePath"))
	else
		
	end
end