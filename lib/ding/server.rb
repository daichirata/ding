module Ding
  class Server
    include ::Ding::Log

    def initialize(host = nil, port = nil, app = nil)
      @app  = app
      @host = host || Const::DEFAULT_HOST
      @port = port || Const::DEFAULT_PORT
      @socket  = TCPServer.new(@host, @port)
      @workers = ThreadGroup.new
    end

    def self.start(host, port, app)
      new(host, port, app).start
    end

    def start
      log ">> Ding #{Const::DING_VERSION}"
      log ">> ruby #{Const::RUBY_INFO}"
      log ">> #{self.class}#start: pid=#{$$} port=#{@port}, CTRL+C to stop"
      debug ">> Debugging ON"
      trace ">> Tracing ON"

      run
    end

  private
    def run
      trap do |socket|
        while true
          begin
            thread = Thread.new(socket.accept) do |client|
              process_client(client)
            end
            thread[:started_on] = Time.now
            @workers.add(thread)
          rescue => e
            log_error e
          end
        end
      end
    end

    def process_client(client)
      begin
        request = Request.parse(client)
        unless Response.send(client, request, @app)
          raise ServerError
        end
      rescue => e
        log_error e
      ensure
        client.close
      end
    end

    def trap
      ['INT', 'TERM'].each do |signal|
        Signal.trap(signal) do
          log ">> going to shutdown ..."
          @workers.list.each {|worker| worker.join}

          log ">> #{self.class}#start done."
          @socket.close; exit 1
        end
      end

      yield @socket
    end
  end
end
