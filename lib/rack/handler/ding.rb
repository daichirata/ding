# -*- coding: utf-8 -*-
require "rack/content_length"
require "rack/chunked"
require File.expand_path(File.dirname(__FILE__) + '/../../ding')

module Rack
  module Handler
    class Ding
      def self.run(app, options={})
        #binding.pry

        server = ::Ding::Server.new(app, options)
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
