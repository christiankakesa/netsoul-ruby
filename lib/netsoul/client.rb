# frozen_string_literal: true

require 'socket'
require_relative '../netsoul'

module Netsoul
  class Client
    attr_reader :started
    SOCKET_READ_TIMEOUT = 12 * 60
    SOCKET_WRITE_TIMEOUT = 1 * 60

    def initialize(*args)
      opts = args.last.is_a?(Hash) ? args.last : {}
      @config = Config.new(opts)
      @started = false
    end

    def auth_ag
      send(Message.auth_ag)
      raise Netsoul::IdentificationError, 'Identification failed.' unless get.split(' ')[1] == '002'
    end
    private :auth_ag

    def auth_method
      if @config.auth_method == :krb5
        send(Message.kerberos_auth(@config))
      else
        send(Message.standard_auth(@config))
      end
      raise Netsoul::AuthenticationError, 'Authentication failed. See your config file or environment variables' \
      unless get.split(' ')[1] == '002'
    end
    private :auth_method

    def auth_status
      send(Message.attach)
      send(Message.user_state(@config.state, Time.now.to_i))
    end
    private :auth_status

    def connect
      @socket = TCPSocket.new(@config.server_host, @config.server_port)
      raise Netsoul::SocketError, 'Could not open a socket. Connection is unavailable.' unless @socket
      _cmd, _socket_num, md5_hash, client_ip, client_port, _server_timestamp = get.split

      @config.build_user_connection_info md5_hash: md5_hash, client_ip: client_ip, client_port: client_port

      auth_ag
      auth_method
      auth_status

      @started = true
    end

    def disconnect
      send(Message.ns_exit)
      close
    ensure
      @started = false
    end

    def send(str)
      _, sock = IO.select(nil, [@socket], nil, SOCKET_WRITE_TIMEOUT)
      s = sock.first
      raise Netsoul::SocketError, 'Timeout or raise on write socket' unless s
      s.puts str
      s.flush
    end

    def get
      sock, = IO.select([@socket], nil, nil, SOCKET_READ_TIMEOUT)
      s = sock.first
      raise Netsoul::SocketError, 'Timeout or raise on read socket' unless s
      res = s.gets.chomp
      if !res.empty?
        res
      else
        'nothing' # Send some string and permit IO.select to thrown exception if something goes wrong.
      end
    end

    private

    def close
      @socket.close if @socket
    end
  end
end
