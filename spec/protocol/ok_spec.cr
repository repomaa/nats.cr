require "../spec_helper"

describe Nats::Protocol::Ok do
  describe ".from_io" do
    it "deserializes the message correctly" do
      io = IO::Memory.new("\r\n")
      Nats::Protocol::Ok.from_io(io)
    end
  end
end
