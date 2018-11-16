module Nats::Protocol
  module ClientMessage
    abstract def to_s(io : IO)
  end
end
