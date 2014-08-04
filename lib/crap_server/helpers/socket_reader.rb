module CrapServer
  module Helpers
    # Makes easier work with sockets and read.
    class SocketReader
      attr_accessor :method
      attr_accessor :socket
      attr_accessor :address
      attr_accessor :config
      def initialize(socket_, method_=:partial)
        @socket = socket_
        @method = method_
      end

      def on_message(&block)
        begin
            if block.parameters.size == 1
              block.call(read_data)
            elsif block.parameters.size == 2
              block.call(read_data, socket)
            else
              block.call(read_data, socket, address)
            end
          # If we get out of data to read (but still having an opened connection), we wait for new data.
        rescue IO::WaitReadable
          # This, prevent to execute so many retry and block the code until a new bunch of data gets available
          IO.select([@socket])
          # Yay!, we have more data. Now we can continue!
          retry
        # When we use non_blocking method, and the client close the connection we will get EOF after that moment
        # We do nothing special in that moment
        rescue EOFError
        end
      end

      protected
      # Read the data from the socket
      def read_data
        # Read the data from the socket
        if @method == :normal
          @socket.read(config.read_buffer_size)
        elsif @method == :partial
          @socket.readpartial(config.read_buffer_size)
        elsif  @method == :non_blocking
          @socket.read_nonblock(config.read_buffer_size)
        end
      end
    end
  end
end