$:.unshift File.expand_path(File.dirname(__FILE__))

require 'socket'
require 'strscan'
require 'uri'

require 'ding/const'
require 'ding/logging'
require 'ding/server'
require 'ding/request'
require 'ding/response'

module Ding
  class ServerError < StandardError; end

  class ParseError < StandardError; end

  class HttpParams < Hash
    attr_accessor :http_body
  end

  Logging.debug = true
  Logging.trace = true
end

if $0 == __FILE__
  Ding::Server.new.start
end
