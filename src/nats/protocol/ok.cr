module Nats::Protocol
  struct Ok
    def self.from_io(io : IO)
      io.gets("\r\n")
      new
    end
  end
end
