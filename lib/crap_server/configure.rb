module CrapServer
  class Configure
    # The port used.
    # Default: 7331
    attr_accessor :port
    # Max read buffer size
    # Default: 16K
    attr_accessor :read_buffer_size
    # The number of maximum penning connections.
    # Default: Max allowed by the OS
    attr_accessor :max_pending_connections
    # Set to false if you want to manage the close of the connection.
    # Note that this require manual_read set to true.
    # DEPERCATED
    attr_accessor :auto_close_connection
    # The file to use as log
    attr_accessor :log_file
    # The log level used
    attr_accessor :log_level
    # Thread pool size. 10 per cor by default
    attr_accessor :pool_size
    def initialize
      @port = 7331
      @manual_read = false
      @read_buffer_size = 1024*16 # 16K for read buffer
      @max_pending_connections = Socket::SOMAXCONN
      @method = :non_blocking
      @auto_close_connection = true
      @log_file = STDOUT
      @log_level = Logger::DEBUG
      @pool_size = 10
    end
  end
end