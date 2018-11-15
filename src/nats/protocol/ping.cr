module Nats::Protocol
  struct Ping
    def self.from_io(io : IO)
      io.gets("\r\n")
      new
    end

    def to_s(io)
      io << "PING\r\n"
    end
  end
end
