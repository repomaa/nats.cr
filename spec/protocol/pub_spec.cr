require "../spec_helper"

describe Nats::Protocol::Pub do
  describe "#to_s" do
    context "without reply-to inbox" do
      it "serializes the message correctly" do
        pub = Nats::Protocol::Pub.new("test_subject", "Test payload!".to_slice)
        pub.to_s.should eq(
          %|PUB test_subject 13\r\nTest payload!\r\n|
        )
      end
    end

    context "with reply-to inbox" do
      it "serializes the message correctly" do
        pub = Nats::Protocol::Pub.new("test_subject", "Test payload!".to_slice, "reply_to")
        pub.to_s.should eq(
          %|PUB test_subject reply_to 13\r\nTest payload!\r\n|
        )
      end
    end
  end
end
