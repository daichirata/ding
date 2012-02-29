module Ding
  class Server
    include ::Ding::Logging

    def initialize(host = nil, port = nil, app = nil)
      @app  = app
      @host = host || '0.0.0.0'
      @port = port || 1212

      @socket = TCPServer.new(@host, @port)
      @workers = ThreadGroup.new
      @timeout = 30
    end

    def self.start(host, port, app)
      new(host, port, app).start
    end

    def start
      log ">> Ding #{DING_VERSION}"
      log ">> ruby #{RUBY_INFO}"
      log ">> Listening on pid=#{$$} port=#{@port}, CTRL+C to stop"
      debug ">> Debugging ON"
      trace ">> Tracing ON"

      run
    end

  private
    def run
      trap {|socket|
        while true
          Thread.start(socket.accept) do |client|
            begin
              thread = Thread.new(client) {|c| process_client(c) }
              thread[:started_on] = Time.now
              @workers.add(thread)
            rescue
              log_error
            end
          end
        end
      }
    end

    def process_client(client)
      begin
        res = Request.parse(client)
        unless Response.send(client, *@app.call(res.env))
          raise ServerError
        end

        #res = Response.new(status, headers, body)
        #client.write(res)
      rescue => e
        log_error e
        #client.write(ERROR_404_RESPONSE)
      ensure
        client.close
      end
    end

    def trap
      ['INT', 'TERM'].each do |signal|
        Signal.trap(signal) do
          @socket.close
          @workers.list.each do |worker|
            worker.raise
          end
          log ">> Stopping ..."; exit 1
        end
      end

      yield @socket
    end
  end
end


