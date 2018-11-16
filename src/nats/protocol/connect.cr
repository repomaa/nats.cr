require "json"
require "../../nats"
require "./client_message"

module Nats::Protocol
  struct Connect
    include ClientMessage
    include JSON::Serializable

    property verbose = false
    property pedantic = false
    property tls_required = false
    property auth_token : String?
    property user : String?
    property pass : String?
    property name : String?

    @lang = "crystal"
    @version = Nats::VERSION
    @protocol = 1
    @echo = false

    def initialize(@echo = false)
    end

    def to_s(io : IO)
      io << "CONNECT "
      to_json(io)
      io << "\r\n"
    end
  end
end
