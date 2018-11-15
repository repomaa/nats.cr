require "../spec_helper"

describe Nats::Protocol::Pong do
  describe ".from_io" do
    it "deserializes the message correctly" do
      io = IO::Memory.new("\r\n")
      Nats::Protocol::Pong.from_io(io)
    end
  end
end
