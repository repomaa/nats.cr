require "../spec_helper"

describe Nats::Protocol::Error do
  describe ".from_io" do
    it "deserializes the message correctly" do
      io = IO::Memory.new("Authorization Violation\r\n")
      error = Nats::Protocol::Error.from_io(io)
      error.message.should eq("Authorization Violation")
    end

    it "raises an error if the message doesn't contain any error message" do
      io = IO::Memory.new
      expect_raises(Nats::Protocol::ProtocolError) do
        Nats::Protocol::Error.from_io(io)
      end
    end
  end

  describe "#keep_open?" do
    it "is false by default" do
      io = IO::Memory.new("Something\r\n")
      error = Nats::Protocol::Error.from_io(io)
      error.keep_open?.should be_false
    end

    it "is true for invalid subject errors" do
      io = IO::Memory.new("Invalid Subject\r\n")
      error = Nats::Protocol::Error.from_io(io)
      error.keep_open?.should be_true
    end

    it "is true for permissions violations" do
      io = IO::Memory.new("Permissions Violation")
      error = Nats::Protocol::Error.from_io(io)
      error.keep_open?.should be_true
    end
  end
end
