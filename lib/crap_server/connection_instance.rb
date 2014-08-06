module CrapServer
  # This is the class used to bind the block that is passed to run!. Every method defined here is available inside
  # the run! block
  class ConnectionInstance
    attr_accessor :socket
    attr_accessor :address
    attr_accessor :config
    attr_accessor :method
    attr_accessor :handler
    def initialize; end

    # This method execute the block sent to run! method
    def run(data, &block)
      # Undefine the last definition if was defined
      undef :call if self.respond_to? :call
      # Define the new method to bind the block with this class.
      self.class.send :define_method, :call, &block
      # Running the code depending of the number of args
      if block.parameters.size == 1
        self.call(data)
      elsif block.parameters.size == 2
        self.call(data, socket)
      else
        self.call(data, socket, address)
      end
      @socket.flush
    end

    # Write to the client the given string
    def write(string)
      @handler.add_to_write @socket
      @handler.set_buffer @socket, string
    end

    def close_after_write
      @handler.set_close_after_write @socket
    end

    def close
      @handler.close @socket
    end

    # Give access to logger class to the user
    def logger
      @config.logger
    end
  end
end