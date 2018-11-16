require "./server_message"
require "./client_message"

module Nats::Protocol
  struct Pong
    include ServerMessage
    include ClientMessage

    def self.from_io(io : IO)
      new
    end

    def to_s(io)
      io << "PONG\r\n"
    end
  end
end
