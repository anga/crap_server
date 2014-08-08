module CrapServer
  class ConnectionHandler

    def initialize(sockets)
      @sockets = sockets
      @sockets.each do |io|
        add_to_read io
      end
    end

    def add_to_write(io)
      @to_write ||= {}
      @to_write[io.fileno] = io
    end

    def to_write
      (@to_write ||= {}).values
    end

    def remove_to_write(io)
      @buffer ||= {}
      @to_write.delete io.fileno
      @buffer.delete io.fileno
    end

    def buffer(io)
      @buffer ||= {}
      @buffer[io.fileno]
    end

    def set_buffer(io, string)
      @buffer ||= {}
      @buffer[io.fileno] = string
    end

    def to_read
      (@to_read ||= {}).values
    end

    def add_to_read(io)
      @to_read ||= {}
      @to_read[io.fileno] = io
    end

    def remove_to_read(io)
      @to_read.delete io.fileno
      @address.delete io.fileno
    end

    def address(io)
      @address ||= {}
      @address[io.fileno]
    end

    def set_address(io, addrs)
      @address ||= {}
      @address[io.fileno] = addrs
    end

    def read_buffer(io)
      @rbuffer ||= {}
      @rbuffer[io.fileno]
    end

    def add_read_buffer(io, string)
      @rbuffer ||= {}
      @rbuffer[io.fileno] ||= ''
      @rbuffer[io.fileno] << string
    end

    def set_close_after_write(io)
      @closeaw ||= {}
      @closeaw[io.fileno] = true
    end

    def close_after_write(io)
      @closeaw ||= {}
      @closeaw[io.fileno]
    end

    def close(io)
      remove_to_read io
      remove_to_write io
      @closeaw ||= {}
      @closeaw.delete io.fileno
      io.close
    end

    def handle(&block)
      # The main loop. Listening IPv4 and IPv6 connections
      accept_loop do |data, remote_socket, address_info|
        instance = CrapServer::ConnectionInstance.new
        instance.socket = remote_socket
        instance.config = config
        instance.address = address_info
        instance.handler = self
        instance.run data, &block
      end
    end

    protected

    # Evented loop (Reactor pattern)
    def accept_loop
      loop {
        @readables,  @writables = IO.select(to_read, to_write)

        @readables.each do |socket|
          if @sockets.include? socket
            io, addr = socket.accept
            set_address io, addr
            set_close_after_write io if config.auto_close_connection
            # Disabling Nagle's algorithm. Is fucking slow :P
            io.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
            # We add him to the read queue
            add_to_read io
          else
            begin
              _, data = socket, socket.read_nonblock(config.read_buffer_size)
              yield data, socket, address(socket)
              # We close the connection if we auto_close_connection is true and the user didn't write in the buffer.
              close socket if config.auto_close_connection && buffer(socket).nil?
            rescue Errno::EAGAIN
            rescue EOFError
              remove_to_read socket
            end
          end
        end

        @writables.each do |socket|
          begin
            string = buffer socket
            bytes = socket.write_nonblock string
            string.slice! 0, bytes
            if string.empty?
              # If we don't have more data to send to the client
              if close_after_write socket
                close socket
              else
                remove_to_write socket
              end
            else
              set_buffer socket, string
              remove_to_read socket
            end
          # If the client close the connection, we remove is from read and from write
          rescue Errno::ECONNRESET, Errno::EPIPE
            if close_after_write socket
              close socket
            end
          end
        end
      }
    end

    protected
    def config
      CrapServer::Application.send(:config)
    end
  end
end