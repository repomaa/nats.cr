module Nats::Protocol
  struct Unsub
    def initialize(@sid : String, @max_messages : Int32? = nil)
    end

    def to_s(io : IO)
      io << "UNSUB " << @sid
      @max_messages.try { |max_messages| io << ' ' << max_messages }
      io << "\r\n"
    end
  end
end
