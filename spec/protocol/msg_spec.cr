require "../spec_helper"

describe Nats::Protocol::Msg do
  describe ".from_io" do
    context "without reply-to inbox" do
      it "deserializes the message correctly" do
        io = IO::Memory.new(%|test_subject subscription_id 13\r\nTest payload!\r\n|)
        msg = Nats::Protocol::Msg.from_io(io)

        msg.subject.should eq("test_subject")
        msg.sid.should eq("subscription_id")
        msg.reply_to.should be_nil
        msg.payload.should eq("Test payload!".to_slice)
      end
    end

    context "with reply-to inbox" do
      it "deserializes the message correctly" do
        io = IO::Memory.new(%|test_subject subscription_id reply_to 13\r\nTest payload!\r\n|)
        msg = Nats::Protocol::Msg.from_io(io)

        msg.subject.should eq("test_subject")
        msg.sid.should eq("subscription_id")
        msg.reply_to.should eq("reply_to")
        msg.payload.should eq("Test payload!".to_slice)
      end
    end

    it "raises an error if the message is invalid" do
      io = IO::Memory.new(%|\r\nTest payload!\r\n|)
      expect_raises(Nats::Protocol::ProtocolError) do
        Nats::Protocol::Msg.from_io(io)
      end
    end
  end
end
