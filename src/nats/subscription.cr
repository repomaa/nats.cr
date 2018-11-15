require "./connection"

module Nats
  class Subscription
    def initialize(@cid : String, @connection : Connection)
      @listeners = [] of Protocol::Msg ->
    end

    def unsubscribe
      @connection.unsubscribe(@cid)
    end

    def on_message(&block : Protocol::Msg ->)
      @listeners << block
    end

    def send(msg : Protocol::Msg)
      @listeners.each(&.call(msg))
    end
  end
end
