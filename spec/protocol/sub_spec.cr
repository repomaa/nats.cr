require "../spec_helper"

describe Nats::Protocol::Sub do
  describe "#to_s" do
    context "without queue group" do
      it "serializes the message correctly" do
        sub = Nats::Protocol::Sub.new("test_subject")
        sub.to_s.should match(
          /^SUB test_subject [a-f0-9]{64}\r\n$/
        )
      end
    end

    context "with queue group" do
      it "serializes the message correctly" do
        sub = Nats::Protocol::Sub.new("test_subject", "test_queue_group")
        sub.to_s.should match(
          /^SUB test_subject test_queue_group [a-f0-9]{64}\r\n$/
        )
      end
    end
  end
end
