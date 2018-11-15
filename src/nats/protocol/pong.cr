module Nats::Protocol
  struct Pong
    def self.from_io(io : IO)
      new
    end

    def to_s(io)
      io << "PONG\r\n"
    end
  end
end
