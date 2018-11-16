require "./client_message"

module Nats::Protocol
  struct Pub
    include ClientMessage

    def initialize(@subject : String, @payload : Bytes, @reply_to : String? = nil)
    end

    def to_s(io : IO)
      io << "PUB " << @subject << ' '
      @reply_to.try { |reply_to| io << reply_to << ' ' }
      io << @payload.size << "\r\n"
      io.write(@payload)
      io << "\r\n"
    end
  end
end
