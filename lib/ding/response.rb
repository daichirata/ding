module Ding
  class Response
    include ::Ding::Log

    def initialize(client, request, app)
      @client  = client
      @request = request
      @status, @headers, @body = app.call(request.env)
      @status = @status.to_i
    end

    def self.send(client, request, app)
      new(client, request, app).send
    end

    def send
      send_status
      send_header
      send_body
      done?
    end

    def send_status
      unless @status_sent
        status = Const::STATUS_FORMAT % [@status, HTTP_STATUS_CODES[@status]]
        @client.write(status)

        @status_sent = true
        #log_access(@request, @status, @headers)
      end
    end

    def send_header
      header = Header.new
      @headers.each do |key, vs|
        next if /\A(?:Date\z|Connection\z)/i =~ key
        vs.split("\n").each{|val| header[key] = val}
      end
      header['Date'] = Time.now.httpdate

      unless @header_sent
        @client.write(header.to_s + Const::LINE_END)
        @header_sent = true
      end
    end

    def send_body
      unless @body_sent
        @body.each do |part|
          @client.write(part)
        end
        @body_sent = true
      end
    end

    def done?
      @status_sent && @header_sent && @body_sent
    end
  end

  class Header
    def initialize
      @sent = {}
      @out  = []
    end

    def has_key?(key)
      @sent[key]
    end

    def []=(key, value)
      if !@sent.has_key?(key) || Const::ALLOWED_DUPLICATES.include?(key)
        @sent[key] = true
        value = case value
                when Time
                  value.httpdate
                when NilClass
                  return
                else
                  value.to_s
                end
        @out << Const::HEADER_FORMAT % [key, value]
      end
    end

    def to_s; @out.join end
  end
end
