module Ding
  class Response
    def initialize(client, status, headers, body)
      @client = client
      @status = status.to_i
      @headers = headers
      @body = body
    end

    attr_reader :status, :headers, :body

    def self.send(client, status, headers, body)
      new(client, status, headers, body).send
    end

    def send
      send_status
      send_header
      send_body
      done?
    end

    def send_status
      unless @status_sent
        @client.write(STATUS_FORMAT % [@status, HTTP_STATUS_CODES[@status]])
        @status_sent = true
      end
    end

    def send_header
      header = Header.new
      @headers.each do |key, vs|
        vs.split("\n").each do |val|
          header[key] = val
        end
      end

      unless @header_sent
        @client.write(header.to_s + LINE_END)
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
    HEADER_FORMAT      = "%s: %s\r\n".freeze
    ALLOWED_DUPLICATES = %w(Set-Cookie Set-Cookie2 Warning WWW-Authenticate).freeze

    def initialize
      @sent = {}
      @out = []
    end

    def []=(key, value)
      if !@sent.has_key?(key) || ALLOWED_DUPLICATES.include?(key)
        @sent[key] = true
        value = case value
                when Time
                  value.httpdate
                when NilClass
                  return
                else
                  value.to_s
                end
        @out << HEADER_FORMAT % [key, value]
      end
    end

    def has_key?(key)
      @sent[key]
    end

    def to_s
      @out.join
    end
  end
end
