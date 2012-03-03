$:.unshift File.expand_path(File.dirname(__FILE__))

require 'socket'
require 'uri'
require 'strscan'
require 'stringio'
require 'time'

require 'ding/const'
require 'ding/log'
require 'ding/connection'
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
