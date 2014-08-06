require 'socket'
require 'logger'

module CrapServer
  class ConnectionError < StandardError; end
  # Example:
  #
  # Crap::Application.run! do |data|
  #   if data =~ /^GET/i
  #     write SomeDatabase.get('column')
  #   elsif data =~/SET/
  #     SomeDatabase.set('column', data.split(' ')[1])
  #   else
  #     write 'Error. Invalid action.'
  #   end
  # end
  class Application
    class << self

      def configure(&block)
        @config ||= CrapServer::Configure.new
        block.yield @config
      end

      # Main method. This setup all the connections and make the logic of the app
      def run!(&block)
        begin
          # Bup the maximum opened file to the maximum allowed by the system
          Process.setrlimit(:NOFILE, Process.getrlimit(:NOFILE)[1])

          # Start IPv4 and IPv6 connection for the current port
          open_connections


          # Some log info to the user :)
          logger.info 'Initializing Crap Server'
          logger.info "Listening 0.0.0.0:#{config.port}"
          logger.debug "Maximum allowed waiting connections: #{Socket::SOMAXCONN}"
          logger.debug "Maximum number of allowed connections: #{Process.getrlimit(:NOFILE)[1]}" # Same as maximum of opened files
          logger.info ''

          # Prefork and handle the connections in each process.
          forker = CrapServer::Forker.new([socket_ipv4, socket_ipv6])
          # Run loop. (basically, waiting until Ctrl+C)
          forker.run &block

          # NOTE: I think this line never will be executed
          close_connections

        # If any kind of error happens, we MUST close the sockets
        rescue => e
          logger.error "Error: #{e.message}"
          e.backtrace.each do |line|
            logger.error line
          end
          close_connections

        rescue Interrupt
          close_connections
        end
      end

      protected

      # Open TCP connection (IPv4 and IPv6)
      def open_connections
        start_ipv4_socket
        start_ipv6_socket
      end

      # Close all the sockets.
      def close_connections
        logger.debug 'Closing all connections.'
        logger.debug 'Bye!'
        # If any kind of error happens, we MUST close the sockets
        if socket_ipv4
          # Shuts down communication on all copies of the connection.
          # socket_ipv4.shutdown
          # socket_ipv4.close
        end

        if socket_ipv6
          # Shuts down communication on all copies of the connection.
          # socket_ipv6.shutdown
          # socket_ipv6.close
        end
        # TODO: Close all opened sockets connections from other threads and processes
      end

      def start_ipv6_socket
        # :INET6 is to open an IPv6 connection
        # :STREAM is to open a TCP socket
        # After this line, the app is not yet ready to work, we only opened a socket
        socket_ipv6 = Socket.new(:INET6, :STREAM)

        begin
          # Now, bind the port.
          # ::1 is loopback for IPv6
          socket_ipv6.bind(Socket.pack_sockaddr_in(config.port, '::1'))
        rescue Errno::EADDRINUSE
          socket_ipv6.close
          raise ConnectionError.new "Unable to bind #{config.port} port."
        end
        socket_ipv6.listen(config.max_pending_connections)
        # Tell to the Kernel that is ok to rebind the port if is in TIME_WAIT state (after close the connection
        # and the Kernel wait for client acknowledgement)
        socket_ipv6.setsockopt(:SOCKET, :REUSEADDR, true)

        @socket6 = socket_ipv6
      end

      def start_ipv4_socket
        # :INET6 is to open an IPv6 connection
        # :STREAM is to open a TCP socket
        # After this line, the app is not yet ready to work, we only opened a socket
        socket_ipv4 = Socket.new(:INET, :STREAM)

        begin
          # Now, bind the port.
          socket_ipv4.bind(Socket.pack_sockaddr_in(config.port, '0.0.0.0'))
        rescue Errno::EADDRINUSE
          socket_ipv4.close
          raise ConnectionError.new "Unable to bind #{config.port} port."
        end

        socket_ipv4.listen(config.max_pending_connections)
        # Tell to the Kernel that is ok to rebind the port if is in TIME_WAIT state (after close the connection
        # and the Kernel wait for client acknowledgement)
        socket_ipv4.setsockopt(:SOCKET, :REUSEADDR, true)

        @socket4 = socket_ipv4
      end

      def socket_ipv6
        @socket6
      end

      def socket_ipv6=(value)
        @socket6 = value
      end

      def socket_ipv4
        @socket4
      end

      def socket_ipv4=(value)
        @socket4 = value
      end

      # TCP Socket reader
      def reader(socket)

      end

      # Main configuration.
      # See Crap::Configure
      def config
        @config ||= CrapServer::Configure.new
      end

      def logger=(value)
        @logger = value
      end

      def logger
        if not @logger
          @logger = Logger.new(config.log_file)
          @logger.level = config.log_level
        end
        @logger
      end
    end
  end
end