# -*- coding: utf-8 -*-
require "rack/content_length"
require "rack/chunked"
require 'pry'
require File.expand_path(File.dirname(__FILE__) + '/../../ding')

module Rack
  module Handler
    class Ding
      def self.run(app, options={})
        #binding.pry

        server =
          ::Ding::Server.new(options[:Host] || '0.0.0.0', options[:Port] || 1212, app)

        yield server if block_given?
        server.start
      end

      def self.valid_options
        {
          "Host=HOST" => "Hostname to listen on (default: localhost)",
          "Port=PORT" => "Port to listen on (default: 8080)",
        }
      end
    end
  end
end
