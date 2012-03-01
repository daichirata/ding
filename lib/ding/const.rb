module Ding

  module Const

    DING_VERSION = '0.0.1'

    DEFAULT_HOST = "0.0.0.0"

    DEFAULT_PORT = 1212

    DEFAULT_LISTEN = "#{DEFAULT_HOST}:#{DEFAULT_PORT}"

    RUBY_INFO = "#{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"

    MAX_BODY = MAX_HEADER = CHUNK_SIZE = 1024 * (80 + 32)

    LINE_END="\r\n".freeze

    STATUS_FORMAT = "HTTP/1.1 %d %s\r\nConnection: close\r\n".freeze

    HEADER_FORMAT      = "%s: %s\r\n".freeze

    ALLOWED_DUPLICATES = %w(Set-Cookie Set-Cookie2 Warning WWW-Authenticate).freeze

    ERROR_404_RESPONSE="HTTP/1.1 404 Not Found\r\nConnection: close\r\nServer: Ding #{DING_VERSION}\r\n\r\nNOT FOUND".freeze

  end

  module Regexep

    REQUEST_LINE = /^(\S+)\s+(\S++)(?:\s+HTTP\/(\d+\.\d+))/mo

    URI   = /\A(#{URI::REGEXP::PATTERN::HOST})(?::(\d+))?\z/no

    FIELD  = /^([A-Za-z0-9!\#$%&'*+\-.^_`|~]+):(.*)\r\n/o

    BORDER = /^\r\n/o

  end

  # Stolent from Mongrel.
  HTTP_STATUS_CODES = {
    100  => 'Continue',
    101  => 'Switching Protocols',
    200  => 'OK',
    201  => 'Created',
    202  => 'Accepted',
    203  => 'Non-Authoritative Information',
    204  => 'No Content',
    205  => 'Reset Content',
    206  => 'Partial Content',
    300  => 'Multiple Choices',
    301  => 'Moved Permanently',
    302  => 'Moved Temporarily',
    303  => 'See Other',
    304  => 'Not Modified',
    305  => 'Use Proxy',
    400  => 'Bad Request',
    401  => 'Unauthorized',
    402  => 'Payment Required',
    403  => 'Forbidden',
    404  => 'Not Found',
    405  => 'Method Not Allowed',
    406  => 'Not Acceptable',
    407  => 'Proxy Authentication Required',
    408  => 'Request Time-out',
    409  => 'Conflict',
    410  => 'Gone',
    411  => 'Length Required',
    412  => 'Precondition Failed',
    413  => 'Request Entity Too Large',
    414  => 'Request-URI Too Large',
    415  => 'Unsupported Media Type',
    500  => 'Internal Server Error',
    501  => 'Not Implemented',
    502  => 'Bad Gateway',
    503  => 'Service Unavailable',
    504  => 'Gateway Time-out',
    505  => 'HTTP Version not supported'
  }
end

