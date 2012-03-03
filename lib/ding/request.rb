module Ding
  class InValidRequest < StandardError; end
  class ParseError < StandardError; end

  class Request
    attr_reader :env

    def initialize(client)
      @peeraddr = client.respond_to?(:peeraddr) ? client.peeraddr : []
      @data     = client.readpartial(Const::CHUNK_SIZE)
      @parser   = Parser.new(@data)
    end

    def self.parse(client)
      new(client).parse
    end

    def parse
      @parser.parse

      @env = {
        # Meta
        "GATEWAY_INTERFACE" => "CGI/1.1",
        "SERVER_NAME"       => @parser.uri.host,
        "SERVER_PORT"       => @parser.uri.port.to_s,
        "SERVER_PROTOCOL"   => "HTTP/1.1",
        "SERVER_SOFTWARE"   => Const::DING_VERSION_STRING,
        "REQUEST_URI"       => @parser.uri.request_uri,
        "REQUEST_METHOD"    => @parser.method,
        "REMOTE_USER"       => "",
        "REMOTE_ADDR"       => @peeraddr[3],
        "REMOTE_HOST"       => @peeraddr[2],
        "PATH_INFO"         => @parser.uri.path,
        "QUERY_STRING"      => (it = @parser.uri.query) ? it : "",
        "SCRIPT_NAME"       => "",

        # Rack
        "rack.version"      => Rack::VERSION,
        "rack.input"        => StringIO.new(@parser.body),
        "rack.errors"       => $stderr,
        "rack.multithread"  => true,
        "rack.multiprocess" => false,
        "rack.run_once"     => false,
        "rack.url_scheme"   => "http"
      }

      @parser.header.each do |key, val|
        case key
        when /^content-type$/io
          @env['CONTENT_TYPE'] = val
        when /^content-length$/io
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

      attr_reader :method, :uri, :header, :body

      def initialize(source)
        @request_line = source.slice!(/(.*)\r\n/).strip
        if Regexep::REQUEST_LINE =~ @request_line
          @method       = $1
          @unparsed_uri = $2
        else
          raise InValidRequest, "bad request line `#@request_line."
        end

        @header = {}
        @body = ""
        super(source)
      end

      def parse
        until eos?
          case
          when scan(Regexep::FIELD)
            field = self[1].strip
            value = self[2].strip

            unless @header.has_key?(field)
              @header[field] = value
            end
          when scan(Regexep::BORDER)
            @body = rest
            break
          else
            raise ParseError "bad request header."
          end
        end
        parse_uri
      end

      def parse_uri
        if request_host = @header["Host"]
          uri = URI.parse(@unparsed_uri)
          host, port = *request_host.scan(Regexep::URI)[0]
          uri.scheme = 'http'
          uri.host = host
          uri.port = port ? port.to_i : nil
          @uri = URI.parse(uri.to_s)
        else
          raise InValidRequest, "no \"Host\" items to the header."
        end
      end
    end # Parser END
  end
end

