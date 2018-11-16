require "./server_message"
require "./client_message"

module Nats::Protocol
  struct Ping
    include ServerMessage
    include ClientMessage

    def self.from_io(io : IO)
      new
    end

    def to_s(io)
      io << "PING\r\n"
    end
  end
end
