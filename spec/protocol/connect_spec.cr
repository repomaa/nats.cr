require "../spec_helper"

describe Nats::Protocol::Connect do
  describe "#to_s" do
    it "serializes the message correctly" do
      connect = Nats::Protocol::Connect.new
      connect.to_s.should eq(
        %|CONNECT {"verbose":true,"pedantic":false,"tls_required":false,"lang":"crystal","version":"#{Nats::VERSION}","protocol":1,"echo":false}\r\n|
      )
    end
  end
end
