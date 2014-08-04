module CrapServer
  class Configure
    # The port used.
    # Default: 7331
    attr_accessor :port
    # Set to true if you want to manage the read.
    # Default false
    attr_accessor :manual_read
    # Max read buffer size
    # Default: 16K
    attr_accessor :read_buffer_size
    # The number of maximum penning connections.
    # Default: Max allowed by the OS
    attr_accessor :max_pending_connections
    # Working method (read, write, accept, connect).
    # Available values are:
    #   :normal
    #   :partial
    #   :non_blocking
    # If :non_blocking is used TODO
    # Default :readpartial
    attr_accessor :method
    # Set to false if you want to manage the close of the connection.
    # Note that this require manual_read set to true.
    attr_accessor :auto_close_connection
    # Logger used to log the app
    attr_accessor :logger
    # The log level used
    attr_accessor :log_level
    def initialize
      @port = 7331
      @manual_read = false
      @read_buffer_size = 1024*16 # 16K for read buffer
      @max_pending_connections = Socket::SOMAXCONN
      @method = :partial
      @auto_close_connection = true
      if not @logger
        @logger = Logger.new(STDOUT)
        @logger.level = config.log_level
      end
      @log_level = :debug
    end
  end
end