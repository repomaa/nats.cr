require "../spec_helper"

describe Nats::Protocol::Info do
  describe ".from_io" do
    it "deserializes the message correctly" do
      io = IO::Memory.new(%|{"server_id":"Zk0GQ3JBSrg3oyxCRRlE09","version":"1.2.0","proto":1,"go":"go1.10.3","host":"0.0.0.0","port":4222,"max_payload":1048576,"client_id":2392}\r\n|)
      info = Nats::Protocol::Info.from_io(io)

      info.server_id.should eq("Zk0GQ3JBSrg3oyxCRRlE09")
      info.version.should eq("1.2.0")
      info.proto.should eq(1)
      info.go.should eq("go1.10.3")
      info.host.should eq("0.0.0.0")
      info.port.should eq(4222)
      info.max_payload.should eq(1048576_u64)
      info.client_id.should eq(2392_u64)
    end

    it "raises an error if the message doesn't contain any info" do
      io = IO::Memory.new
      expect_raises(Nats::Protocol::ProtocolError) do
        Nats::Protocol::Info.from_io(io)
      end
    end

    it "raises an error if the message can't be parsed" do
      io = IO::Memory.new(%|{invalid:json}|)
      expect_raises(Nats::Protocol::ProtocolError) do
        Nats::Protocol::Info.from_io(io)
      end
    end
  end
end
