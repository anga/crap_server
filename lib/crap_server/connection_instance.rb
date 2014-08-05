module CrapServer
  # This is the class used to bind the block that is passed to run!. Every method defined here is available inside
  # the run! block
  class ConnectionInstance
    attr_accessor :socket
    attr_accessor :address
    attr_accessor :config
    attr_accessor :method
    def initialize; end

    # This method execute the block sent to run! method
    def run(&block)
      # Undefine the last definition if was defined
      undef :call if self.respond_to? :call
      # Define the new method to bind the block with this class.
      self.class.send :define_method, :call, &block
      # Running the code depending of the number of args
      if block.parameters.size == 1
        self.call(read_data)
      elsif block.parameters.size == 2
        self.call(read_data, socket)
      else
        self.call(read_data, socket, address)
      end
    end

    # Write to the client the given string
    def write(string)
      begin
        if @method == :normal or @method == :partial
          @socket.write(string)
        elsif  @method == :non_blocking
          @socket.write_nonblock(string)
        end
      rescue IO::WaitWritable, Errno::EINTR
        IO.select(nil, [@socket], nil, config.timeout)
      end
    end

    # Give access to logger class to the user
    def logger
      @config.logger
    end
    protected
    # Read the data from the socket
    def read_data
      begin
        # Read the data from the socket
        if @method == :normal
          @socket.read(config.read_buffer_size)
        elsif @method == :partial
          @socket.readpartial(config.read_buffer_size)
        elsif  @method == :non_blocking
          @socket.read_nonblock(config.read_buffer_size)
        end
      rescue Errno::EAGAIN
        IO.select([connection],nil,nil, config.timeout)
        retry
      end
    end
  end
end