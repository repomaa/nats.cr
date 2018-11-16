require "./server_message"

module Nats::Protocol
  struct Ok
    include ServerMessage

    def self.from_io(io : IO)
      new
    end
  end
end
