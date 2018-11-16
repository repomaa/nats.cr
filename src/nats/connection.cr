require "logger"
require "socket"
require "uri"
require "openssl"
require "./protocol/*"
require "./subscription"

module Nats
  class Connection
    class ClosedError < Exception
    end

    getter? closed

    def initialize(
      host, port,
      @key : String? = nil,
      @cert : String? = nil,
      @ca : String? = nil,
      @user : String? = nil,
      @pass : String? = nil,
      @token : String? = nil,
      @echo = false,
      @client_name : String? = nil,
      @logger : Logger = Logger.new(STDERR)
    )
      @socket = TCPSocket.new(host, port)
      @subscriptions = {} of String => Subscription
      @max_message_counters = {} of String => Int32
      @closed = false
      @inbox = Channel(Protocol::ServerMessage?).new(128)
      @outbox = Channel(Protocol::ClientMessage?).new(128)

      spawn inbox
      spawn outbox
      spawn listen
    end

    def self.new(url, **args)
      new(URI.parse(url), **args)
    end

    def self.new(uri : URI, **args)
      host = uri.host
      port = uri.port
      raise "Invalid uri" if host.nil? || port.nil?

      new(host, port, **args)
    end

    def close
      @socket.close unless closed?
      @closed = true
      @inbox.send(nil)
      @outbox.send(nil)
    end

    def listen
      until closed?
        message = @inbox.receive
        break if message.nil?
        handle_message(message)
      end
    ensure
      close
    end

    def subscribe(subject : String, queue_group : String? = nil)
      raise ArgumentError.new("Connection closed") if closed?
      sub_message = Protocol::Sub.new(subject, queue_group)
      sid = sub_message.sid

      Subscription.new(sid, self).tap do |subscription|
        @subscriptions[sid] = subscription
        @outbox.send(sub_message)
      end
    end

    def unsubscribe(sid : String, max_messages : Int32? = nil)
      raise ArgumentError.new("Connection closed") if closed?
      unsub_message = Protocol::Unsub.new(sid, max_messages)

      @max_message_counters[sid] = max_messages if max_messages
      @outbox.send(unsub_message)
      @subscriptions.delete(sid) unless max_messages
    end

    def publish(subject : String, payload)
      raise ArgumentError.new("Connection closed") if closed?
      pub_message = Protocol::Pub.new(subject, payload.to_slice)
      @outbox.send(pub_message)
    end

    private def inbox
      until closed?
        begin
          message = read_protocol_message
          @inbox.send(message)
        rescue ex : ClosedError
          STDERR.puts(ex)
          close
        rescue ex : Protocol::ProtocolError
          STDERR.puts(ex)
        end
      end
    end

    private def outbox
      until closed?
        message = @outbox.receive
        break if message.nil?
        @socket << message
      end
    end

    private def handle_message(error : Protocol::Err)
      close unless error.keep_open?
      raise Protocol::ProtocolError.new(error.message)
    end

    private def handle_message(info : Protocol::Info)
      puts info.inspect
      info.connect_urls.try do |urls|
        url = urls.sample
        next if url.nil?
        reconnect(url)
      end

      initiate_tls(info) if info.tls_required?
      connect(info)
    end

    private def reconnect(url)
      uri = URI.parse(url)
      @socket.close
      host = uri.host
      port = uri.port
      if host.nil? || port.nil?
        raise Protocol::ProtocolError.new("Invalid connect_url '#{url}'")
      end

      @socket = TCPSocket.new(host, port)
    end

    private def handle_message(msg : Protocol::Msg)
      sid = msg.sid
      @subscriptions[sid]?.try(&.send(msg))

      if @max_message_counters.has_key?(sid)
        counter = @max_message_counters[sid] -= 1
        @subscriptions.delete(sid) if counter < 1
      end
    end

    private def handle_message(ok : Protocol::Ok)
    end

    private def handle_message(ping : Protocol::Ping)
      @outbox.send(Protocol::Pong.new)
    end

    private def handle_message(pong : Protocol::Pong)
    end

    private def read_protocol_message
      type = read_type
      case type.try(&.upcase)
      when "-ERR" then Protocol::Err.from_io(@socket)
      when "INFO" then Protocol::Info.from_io(@socket)
      when "MSG" then Protocol::Msg.from_io(@socket)
      when "+OK" then Protocol::Ok.from_io(@socket)
      when "PING" then Protocol::Ping.from_io(@socket)
      when "PONG" then Protocol::Pong.from_io(@socket)
      when nil then raise ClosedError.new("Connection closed")
      else raise Protocol::ProtocolError.new("Unsupported protocol message '#{type}' received")
      end
    end

    private def read_type
      String.build do |io|
        loop do
          char = @socket.read_char
          raise ClosedError.new("Connection closed") if char.nil?
          break if char == ' ' || char == '\r' && @socket.read_char == '\n'
          io << char
        end
      end
    end

    private def connect(info)
      user = @user
      pass = @pass
      token = @token

      connect_message = Protocol::Connect.new(@echo)

      if user && pass
        connect_message.user = user
        connect_message.pass = pass
      elsif token
        connect_message.auth_token = token
      elsif info.auth_required?
        raise "Authentication required but neither user/pass nor token was given"
      end

      @outbox.send(connect_message)
    end

    private def initiate_tls(info)
      context = OpenSSL::SSL::Context::Client.new
      key = @key
      cert = @cert

      if key && cert
        context.private_key = key
        context.certificate_chain = cert
      elsif info.tls_verify?
        raise "Server requires tls verification but no key or cert was given"
      end

      @ca.try { |ca| context.ca_certificates = ca }
      @socket = OpenSSL::SSL::Socket::Client.new(@socket, context)
    end
  end
end
