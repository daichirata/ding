module Ding
  class Server
    include ::Ding::Log

    def initialize(app, options)
      @app  = app
      @host = options[:Host] || Const::DEFAULT_HOST
      @port = options[:Port] || Const::DEFAULT_PORT
      @socket  = TCPServer.new(@host, @port)
      @workers = ThreadGroup.new

      log ">> Ding #{Const::DING_VERSION}"
      log ">> ruby #{Const::RUBY_INFO}"
    end

    def start
      raise ArgumentError, 'app required' unless @app

      log ">> #{self.class}#start: pid=#{$$} port=#{@port}, CTRL+C to stop"
      debug ">> Debugging ON"

      trap do |socket|
        while true
          begin
            thread = Thread.new(socket.accept) do |client|
              process_client(client)
            end

            thread[:started_on] = Time.now
            @workers.add(thread)
          rescue
            log_error
          end
        end
      end
    end

    def process_client(client)
      begin
        request = Request.parse(client)
        status, headers, body = @app.call(request.env)

        response = Response.new(client)
        response.call(status, headers, body)
      rescue
        log_error
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
