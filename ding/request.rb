require 'stringio'
module Ding
  class Request
    def initialize(client)
      @request_time = Time.now

      @data = client.readpartial(CHUNK_SIZE)
      @parser = Parser.new(@data)
      @addr     = client.respond_to?(:addr)     ? client.addr     : []
      @peeraddr = client.respond_to?(:peeraddr) ? client.peeraddr : []
    end

    attr_reader :env

    def self.parse(client)
      new(client).parse
    end

    def parse
      @parser.parse

      @env = {
        "GATEWAY_INTERFACE" => "CGI/1.1",
        "PATH_INFO"         => @parser.request_uri.path,
        "QUERY_STRING"      => it = @parser.request_uri.query ? it.dup : "",
        "SCRIPT_NAME"       => "",
        "SERVER_NAME"       => @parser.request_uri.host,
        "SERVER_PORT"       => @parser.request_uri.port.to_s,
        "SERVER_PROTOCOL"   => HTTP_PROTOCOL,
        "SERVER_SOFTWARE"   => DING_INFO,
        "REQUEST_METHOD"    => @parser.request_method,
        "REQUEST_URI"       => @parser.request_uri.request_uri,
        "REMOTE_USER"       => "",
        "REMOTE_ADDR"       => @peeraddr[3],
        "REMOTE_HOST"       => @peeraddr[2],

        "rack.version"      => Rack::VERSION,
        "rack.input"        => StringIO.new(@parser.message_body),
        "rack.errors"       => $stderr,
        "rack.multithread"  => true,
        "rack.multiprocess" => false,
        "rack.run_once"     => false,
        "rack.url_scheme"   => "http"
      }

      @parser.request_header.each do |key, val|
        case key
        when /^content-type$/i
          @env['CONTENT_TYPE'] = val
        when /^content-length$/i
          @env['CONTENT_LENGTH'] = val if val.to_i > 0
        else
          name = "HTTP_" << key.gsub(/-/o, '_').upcase
          @env[name] = val
        end
      end
      return self
    end

    class Parser < StringScanner
      # attr_reader :request_line, :request_method, :request_uri,
      #             :request_header, :http_version, :message_body

      attr_reader :request_header, :request_method, :request_uri, :message_body

      def initialize(source)
        @request_line = source.slice!(/(.*)\r\n/).strip
        if REQUEST_LINE_REGEXP =~ @request_line
          @request_method = $1
          @unparsed_uri   = $2
          @http_version   = $3
        else
          raise ParseError
        end

        @request_header = {}
        @message_body = ""
        super(source)
      end

      def parse
        until eos?
          case
          when scan(FIELD_REGEXP)
            field = self[1].strip
            value = self[2].strip

            unless @request_header.has_key?(field)
              @request_header[field] = value
            end
          when scan(BORDER_REGEXP)
            @message_body = rest
            break
          else
            raise ParseError
          end
        end
        parse_uri
      end

      def parse_uri
        if request_host = @request_header["Host"]
          uri = URI.parse(@unparsed_uri)
          host, port = *request_host.scan(URI_REGEXEP)[0]
          uri.scheme = 'http'
          uri.host, uri.port = host, port ? port.to_i : nil
          @request_uri = URI.parse(uri.to_s)
        else
          raise ParseError
        end
      end
    end
  end
end
