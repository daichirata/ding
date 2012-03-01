module Ding
  class Server
    include ::Ding::Log

    def initialize(host = nil, port = nil, app = nil)
      @app  = app
      @host = host || '0.0.0.0'
      @port = port || 1212

      @socket  = TCPServer.new(@host, @port)
      @workers = ThreadGroup.new

      log ">> Ding #{DING_VERSION}"
      log ">> ruby #{RUBY_INFO}"
    end

    def self.start(host, port, app)
      new(host, port, app).start
    end

    def start
      log   ">> Listening on pid=#{$$} port=#{@port}, CTRL+C to stop"
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
        res = Request.parse(client)
        unless Response.send(client, *@app.call(res.env))
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
          @socket.close

          log ">> Stopping ..."; exit 1
        end
      end

      yield @socket
    end
  end
end
