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

        # The main loop. Listening IPv4 and IPv6 connections
        Socket.accept_loop([socket_ipv4, socket_ipv6]) do |remote_socket, address_info|
          connection_loop(remote_socket, address_info, &block)
        end

        close_connections
      # If any kind of error happens, we MUST close the sockets
      rescue => e
        close_connections

        raise e
      end

      protected
      def connection_loop(remote_socket, addres_info, &block)
          # Work with the connection...
          if we_should_read?
            reader = CrapServer::Helpers::SocketReader.new(remote_socket, config.method)
            reader.address = addres_info
            reader.config = config
            reader.on_message(&block)
          else
            begin
              if block.parameters == 1
                block.call(remote_socket)
              else
                block.call(remote_socket, addres_info)
              end
                # If we get out of data to read (but still having an opened connection), we wait for new data.
            rescue IO::WaitReadable
              # This, prevent to execute so many retry and block the code until a new bunch of data gets available
              IO.select([remote_socket])
              # Yay!, we have more data. Now we can continue!
              retry
            end
          end
          # ...

        # Close the connection
        remote_socket.close if config.auto_close_connection
      end

      # Return true or false if the read process is done by the server.
      def we_should_read?
        not config.manual_read
      end

      # Open TCP connection (IPv4 and IPv6)
      def open_connections
        start_ipv4_socket
        start_ipv6_socket
      end

      # Close all the sockets.
      def close_connections
        # If any kind of error happens, we MUST close the sockets
        if socket_ipv4
          # Shuts down communication on all copies of the connection.
          socket_ipv4.shutdown
          socket_ipv4.close
        end

        if socket_ipv6
          # Shuts down communication on all copies of the connection.
          socket_ipv6.shutdown
          socket_ipv6.close
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

        puts "config: #{config.manual_read}"

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
        @config
      end

      def logger=(value)
        @logger = value
      end

      def logger
        @logger ||= config.logger
      end
    end
  end
end