module CrapServer
  class ThreadPool
    def initialize(sockets)
      @sockets = sockets
    end

    def run(&block)
      @block = block
      Thread.abort_on_exception = true
      threads = ThreadGroup.new
      config.pool_size.times do
        threads.add spawn_thread
      end

      sleep
    end

    protected

    def spawn_thread
      Thread.new {
        handler = CrapServer::ConnectionHandler.new @sockets
        handler.handle &@block
      }
    end

    def config
      CrapServer::Application.send(:config)
    end
  end
end