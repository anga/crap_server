module CrapServer
  # Handle preforking task.
  # Will spawn 1 process per core.
  class Forker
    def initialize(sockets)
      @sockets = sockets
    end

    # Initialize
    def run(&block)
      begin
        @block_proc = block
        child_pids = []
        processor_count.times do
          child_pids << spawn_child
        end

        # We take care of our children. If someone kill one, me made another one.
        # PS: Is a hard work :P
        loop do
          pid = Process.wait
          child_pids.delete(pid)
          child_pids << spawn_child
        end
      # If someone kill us, we kill our children. Yes, is sad, but we must do it :'(
      rescue Interrupt
        child_pids.each do |cpid|
          begin
            # We send Ctrl+C to the process
            Process.kill(:INT, cpid)
          rescue Errno::ESRCH
          end
        end
        @sockets.each do |socket|
          # Shuts down communication on all copies of the connection.
          socket.shutdown
          socket.close
        end

      end
    end

    protected

    def spawn_child
      fork do
        begin
          pool = CrapServer::ThreadPool.new @sockets
          pool.run &@block_proc
        rescue Interrupt
        end
      end
    end

    # Extracted from https://github.com/grosser/parallel/blob/master/lib/parallel.rb
    # Number of processors seen by the OS and used for process scheduling.
    #
    # * AIX: /usr/sbin/pmcycles (AIX 5+), /usr/sbin/lsdev
    # * BSD: /sbin/sysctl
    # * Cygwin: /proc/cpuinfo
    # * Darwin: /usr/bin/hwprefs, /usr/sbin/sysctl
    # * HP-UX: /usr/sbin/ioscan
    # * IRIX: /usr/sbin/sysconf
    # * Linux: /proc/cpuinfo
    # * Minix 3+: /proc/cpuinfo
    # * Solaris: /usr/sbin/psrinfo
    # * Tru64 UNIX: /usr/sbin/psrinfo
    # * UnixWare: /usr/sbin/psrinfo
    #
    def processor_count
      @processor_count ||= begin
        os_name = RbConfig::CONFIG["target_os"]
        if os_name =~ /mingw|mswin/
          require 'win32ole'
          result = WIN32OLE.connect("winmgmts://").ExecQuery(
              "select NumberOfLogicalProcessors from Win32_Processor")
          result.to_enum.collect(&:NumberOfLogicalProcessors).reduce(:+)
        elsif File.readable?("/proc/cpuinfo")
          IO.read("/proc/cpuinfo").scan(/^processor/).size
        elsif File.executable?("/usr/bin/hwprefs")
          IO.popen("/usr/bin/hwprefs thread_count").read.to_i
        elsif File.executable?("/usr/sbin/psrinfo")
          IO.popen("/usr/sbin/psrinfo").read.scan(/^.*on-*line/).size
        elsif File.executable?("/usr/sbin/ioscan")
          IO.popen("/usr/sbin/ioscan -kC processor") do |out|
            out.read.scan(/^.*processor/).size
          end
        elsif File.executable?("/usr/sbin/pmcycles")
          IO.popen("/usr/sbin/pmcycles -m").read.count("\n")
        elsif File.executable?("/usr/sbin/lsdev")
          IO.popen("/usr/sbin/lsdev -Cc processor -S 1").read.count("\n")
        elsif File.executable?("/usr/sbin/sysconf") and os_name =~ /irix/i
          IO.popen("/usr/sbin/sysconf NPROC_ONLN").read.to_i
        elsif File.executable?("/usr/sbin/sysctl")
          IO.popen("/usr/sbin/sysctl -n hw.ncpu").read.to_i
        elsif File.executable?("/sbin/sysctl")
          IO.popen("/sbin/sysctl -n hw.ncpu").read.to_i
        else
          $stderr.puts "Unknown platform: " + RbConfig::CONFIG["target_os"]
          $stderr.puts "Assuming 1 processor."
          1
        end
      end
    end


  end
end