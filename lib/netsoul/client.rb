# frozen_string_literal: true

require_relative '../netsoul'
require 'socket'

module Netsoul
  class Client
    include Logging
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
      raise Netsoul::IdentificationError, 'Identification failed.'.freeze unless get.split(' '.freeze)[1] == '002'.freeze
    end
    private :auth_ag

    def auth_method
      if @config.auth_method == :krb5
        send(Message.kerberos_auth(@config))
      else
        send(Message.standard_auth(@config))
      end
      raise Netsoul::AuthenticationError, 'Authentication failed. See your config file or environment variables'.freeze \
      unless get.split(' '.freeze)[1] == '002'.freeze
    end
    private :auth_method

    def auth_status
      send(Message.attach)
      send(Message.user_state(@config.state, Time.now.to_i))
    end
    private :auth_status

    def connect
      @socket = TCPSocket.new(@config.server_host, @config.server_port)
      raise Netsoul::SocketError, 'Could not open a socket. Connection is unavailable.'.freeze unless @socket
      _cmd, _socket_num, md5_hash, client_ip, client_port, _server_timestamp = get.split

      @config.build_user_connection_info md5_hash: md5_hash, client_ip: client_ip, client_port: client_port

      auth_ag
      auth_method
      auth_status

      @started = true
    end

    def disconnect
      send(Message.ns_exit)
    ensure
      close
    end

    def send(str)
      _, sock = IO.select(nil, [@socket], nil, SOCKET_WRITE_TIMEOUT)
      raise Netsoul::SocketError, 'Timeout or raise on write socket'.freeze if sock.nil? || sock.empty?
      s = sock.first
      if s
        s.puts str
        s.flush
      end
      log :info, "[send] #{str.chomp}"
    end

    def get
      sock, = IO.select([@socket], nil, nil, SOCKET_READ_TIMEOUT)
      raise Netsoul::SocketError, 'Timeout or raise on read socket'.freeze if sock.nil? || sock.empty?
      res = sock.first.gets
      if res
        log :info, "[get ] #{res.chomp}"
        res
      else
        'nothing'.freeze # Send some string and permit IO.select to thrown exception if something goes wrong.
      end
    end

    def close
      @started = false
      @socket.close
    rescue
      nil
    end
  end
end
