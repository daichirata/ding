module Ding
  class Response
    include ::Ding::Log

    def initialize(socket)
      @socket = socket

      @params = HeaderParams.new
      @output = []
      @finished = false
      @chunked = false
    end

    def call(status, headers, body)
      @head = Const::STATUS_FORMAT % [status, HTTP_STATUS_CODES[status.to_i]]

      if body.kind_of?(String)
        headers["Content-Length"] = body.length.to_s
        body = [body]
      end

      if headers["Transfer-Encoding"] == "chunked" || !headers.has_key?("Content-Length")
        headers["Transfer-Encoding"] = "chunked"
        @chunked = true
      end

      @params['Date'] = Time.now
      headers.each do |key, vs|
        vs.split("\n").each{|val| @params[key] = val}
      end
      @head << @params.to_s << "\r\n"

      if headers["Content-Length"] != "0"
        body.each{|chunk| write(chunk)}
      else
        write('')
      end

      @finished = true
      write('') if @chunked

      body.close if body.respond_to?(:close)
    end

    def write(chunk)
      encoded =
        @chunked ? "#{chunk.length.to_s(16)}\r\n#{chunk}\r\n" : chunk

      if @head.nil?
        @output << encoded
      else
        @output << @head + encoded
        @head = nil
      end

      @socket.write(@output.join)
    end
  end

  class HeaderParams
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
