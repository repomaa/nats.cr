module Nats::Protocol
  struct Pong
    def self.from_io(io : IO)
      io.gets("\r\n")
      new
    end

    def to_s(io)
      io << "PONG\r\n"
    end
  end
end
