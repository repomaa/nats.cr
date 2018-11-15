require "json"
require "./message"

module Nats::Protocol
  struct Info < Message
    include JSON::Serializable

    getter server_id : String
    getter version : String
    getter go : String
    getter host : String
    getter port : Int32
    getter max_payload : UInt64
    getter proto : Int32
    getter client_id : UInt64?
    getter? auth_required = false
    getter? tls_required = false
    getter? tls_verify = false
    getter connect_urls : Array(String)?

    def self.from_io(io : IO)
      info = io.gets("\r\n")
      if info.nil?
        raise ProtocolError.new("No info in INFO protocol message")
      end

      pull_parser = JSON::PullParser.new(info)
      new(pull_parser)
    rescue ex : JSON::ParseException
      raise ProtocolError.new("Failed to parse info from INFO protocol message: #{ex.message}")
    end
  end
end
