require "rack/content_length"
require "rack/chunked"
require File.expand_path(File.dirname(__FILE__) + '/../../ding')

module Rack
  module Handler
    class Ding
      def self.run(app, options={})
        options = {
          :host => options[:Host],
          :port => options[:Port]
        }

        ::Ding::Server.new(app, options).run
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
