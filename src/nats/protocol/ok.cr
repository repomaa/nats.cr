module Nats::Protocol
  struct Ok
    def self.from_io(io : IO)
      new
    end
  end
end
