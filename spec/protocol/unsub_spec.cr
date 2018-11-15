require "../spec_helper"

describe Nats::Protocol::Unsub do
  describe "#to_s" do
    context "without max_messages" do
      it "serializes the message correctly" do
        unsub = Nats::Protocol::Unsub.new("test_sid")
        unsub.to_s.should eq("UNSUB test_sid\r\n")
      end
    end

    context "with max_messages" do
      it "serializes the message correctly" do
        unsub = Nats::Protocol::Unsub.new("test_sid", 1024)
        unsub.to_s.should eq("UNSUB test_sid 1024\r\n")
      end
    end
  end
end
