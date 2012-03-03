class Ding::Connection
  class << self
    attr_writer :host, :port

    def listen_on(&block)
      block.call(self)

      init_socket
      init_workers
    end

    def accept(&block)
      Thread.fork(@socket.accept, &block)
    end

    def add_workers(worker)
      worker[:started_on] = Time.now
      @workers.add(worker)
    end

    def close
      stop_workers
      close_socket
    end

    def init_socket
      @socket = TCPServer.new(@host, @port)
    end

    def init_workers
      @workers = ThreadGroup.new
    end

    def stop_workers
      @workers.list.each {|worker| worker.join}
    end

    def close_socket
      @socket.close
    end
  end
end
