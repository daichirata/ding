$:.unshift File.expand_path(File.dirname(__FILE__))

require 'socket'
require 'uri'
require 'strscan'
require 'stringio'

require 'ding/const'
require 'ding/log'
require 'ding/server'
require 'ding/request'
require 'ding/response'

module Ding
  class ServerError < StandardError; end
  class ParseError < StandardError; end

  Log.silent = false
  Log.debug  = true
  #Log.trace = true
end

# for debug
if $0 == __FILE__
  Ding::Server.new.start
end
