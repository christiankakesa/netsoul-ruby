require_relative '../netsoul'
require 'socket'

module Netsoul
  class Client
    include Logging
    attr_reader :started
    SOCKET_READ_TIMEOUT = 12 * 60
    SOCKET_WRITE_TIMEOUT = 10

    def initialize(*args)
      opts = args.last.is_a?(Hash) ? args.last : {}
      @config = Config.new(opts)
      @started = false
    end

    def auth_ag
      sock_send(Message.auth_ag)
      fail Netsoul::IdentificationError, 'Identification failed.'.freeze unless sock_get.split(' ')[1] == '002'.freeze
    end
    private :auth_ag

    def auth_method
      if @config.auth_method == :krb5
        sock_send(Message.kerberos_auth(@config))
      else
        sock_send(Message.standard_auth(@config))
      end
      fail Netsoul::AuthenticationError, 'Authentication failed. See your config file or environment variables'.freeze unless sock_get.split(' ')[1] == '002'
    end
    private :auth_method

    def auth_status
      sock_send(Message.attach)
      sock_send(Message.user_state(@config.state, Time.now.to_i))
    end
    private :auth_status

    def connect
      @sock = TCPSocket.new(@config.server_host, @config.server_port)
      fail Netsoul::SocketError, 'Could not open a socket. Connection is unavailable.'.freeze unless @sock
      _cmd, _socket_num, md5_hash, client_ip, client_port, _server_timestamp = sock_get.split

      @config.build_user_connection_info md5_hash: md5_hash, client_ip: client_ip, client_port: client_port

      auth_ag
      auth_method
      auth_status

      @started = true
    end

    def disconnect
      sock_send(Message.ns_exit)
    ensure
      sock_close
    end

    def sock_send(str)
      _, sock = IO.select(nil, [@sock], nil, SOCKET_WRITE_TIMEOUT)
      fail Netsoul::SocketError, 'Timeout or fail on write socket' if sock.nil? || sock.empty?
      sock.first.puts str
      log :info, "[send] #{str.chomp}"
    end

    def sock_get
      sock, = IO.select([@sock], nil, nil, SOCKET_READ_TIMEOUT)
      fail Netsoul::SocketError, 'Timeout or fail on read socket' if sock.nil? || sock.empty?
      res = sock.first.gets
      log :info, "[get ] #{res.chomp}" if res
      res || ''
    end

    def sock_close
      @started = false
      @sock.close
    rescue
      nil
    end
  end
end
