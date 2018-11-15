require "./protocol_error"

module Nats::Protocol
  struct Error
    BENIGN_ERRORS = [
      "Invalid Subject",
      "Permissions Violation"
    ]

    getter message : String

    private def initialize(@message)
    end

    def keep_open?
      BENIGN_ERRORS.any? do |benign_message|
        message.starts_with?(benign_message)
      end
    end

    def self.from_io(io : IO)
      message = io.gets("\r\n", chomp: true)
      if message.nil?
        raise ProtocolError.new("No error message in -ERROR protocol message")
      end

      new(message)
    end
  end
end
