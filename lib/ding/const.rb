module Ding
  DING_VERSION = VERSION = '0.0.1'.freeze

  RUBY_INFO = "#{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]".freeze

  DING_INFO = "Ding/#{DING_VERSION} (Ruby/#{RUBY_VERSION}/#{RUBY_RELEASE_DATE})".freeze

  HTTP_PROTOCOL = "HTTP/1.1".freeze

  MAX_BODY = MAX_HEADER = CHUNK_SIZE = 1024 * (80 + 32)

  REQUEST_BODY_TMPFILE = 'ding-body'.freeze

  FIELD_REGEXP  = /^([A-Za-z0-9!\#$%&'*+\-.^_`|~]+):(.*)\r\n/o
  BORDER_REGEXP = /^\r\n/o
  URI_REGEXEP   = /\A(#{URI::REGEXP::PATTERN::HOST})(?::(\d+))?\z/no
  REQUEST_LINE_REGEXP = /^(\S+)\s+(\S++)(?:\s+HTTP\/(\d+\.\d+))/mo

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

  LINE_END="\r\n".freeze

  STATUS_FORMAT = "HTTP/1.1 %d %s\r\nConnection: close\r\n".freeze

  ERROR_404_RESPONSE="HTTP/1.1 404 Not Found\r\nConnection: close\r\nServer: Ding #{DING_VERSION}\r\n\r\nNOT FOUND".freeze
end

