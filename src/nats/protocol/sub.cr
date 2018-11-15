module Nats::Protocol
  struct Sub
    getter sid

    def initialize(@subject : String, @queue_group : String? = nil)
      @sid = Random::Secure.hex(32)
    end

    def to_s(io : IO)
      io << "SUB " << @subject << ' '
      @queue_group.try { |queue_group| io << queue_group << ' ' }
      io << @sid << "\r\n"
    end
  end
end
