module Ding
  class Server
    include ::Ding::Log

    def initialize(app, options = {})
      Connection.listen_on do |server|
        server.host = options[:host] || Const::DEFAULT_HOST
        server.port = options[:port] || Const::DEFAULT_PORT
      end

      @app = app
    end

    def run
      log ">> #{self.class}#start pid=#{$$} port=#{@port}, CTRL+C to stop"

      trap do
        while true
          begin
            worker = Connection.accept do |client|
              process_client(client)
            end

            Connection.add_workers(worker)
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
      ensure
        client.close
      end
    end

    def trap
      ['INT', 'TERM'].each do |signal|
        Signal.trap(signal) do
          log ">> going to shutdown ..."
          Connection.close; exit 1
        end
      end

      yield
    end
  end
end
