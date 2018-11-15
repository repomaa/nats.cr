module Nats::Protocol
  struct Ping
    def self.from_io(io : IO)
      new
    end

    def to_s(io)
      io << "PING\r\n"
    end
  end
end
