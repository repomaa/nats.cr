require "json"
require "./server_message"
require "./protocol_error"

module Nats::Protocol
  struct Msg
    include ServerMessage

    getter subject : String
    getter sid : String
    getter reply_to : String?
    getter payload : Bytes

    def payload_string
      String.new(payload)
    end

    private def initialize(@subject, @sid, @payload, @reply_to = nil)
    end

    def self.from_io(io : IO)
      subject = io.gets(' ', chomp: true)
      if subject.nil?
        raise ProtocolError.new("Missing subject in MSG protocol message")
      end

      sid = io.gets(' ', chomp: true)
      if sid.nil?
        raise ProtocolError.new("Missing sid in MSG protocol message")
      end

      rest = io.gets("\r\n", chomp: true)
      if rest.nil?
        raise ProtocolError.new("Missing bytesize and/or reply_to inbox in MSG protocol message")
      end

      rest_fields = rest.split(' ')
      bytesize = rest_fields.last?.try(&.to_i)

      if bytesize.nil?
        raise ProtocolError.new("Missing bytesize in MSG protocol message")
      end

      reply_to = rest_fields.size > 1 ? rest_fields.first : nil
      payload = Bytes.new(bytesize)
      bytes_read = io.read(payload)
      if bytes_read < bytesize
        raise ProtocolError.new("Less than bytesize could be read from MSG payload")
      end

      io.gets("\r\n")

      new(subject, sid, payload, reply_to)
    end
  end
end
