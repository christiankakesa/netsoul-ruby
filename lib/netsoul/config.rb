# frozen_string_literal: true

module Netsoul
  class Config
    AUTH_METHODS = [:std, :krb5].freeze
    USER_STATES = [:actif, :away, :connection, :idle, :lock, :server, :none].freeze
    VALID_USER_CONNECTION_INFO = [:md5_hash, :client_ip, :client_port].freeze

    attr_accessor :server_host,
                  :server_port,
                  :login,
                  :socks_password,
                  :unix_password,
                  :auth_method,
                  :state,
                  :location,
                  :user_group,
                  :user_connection_info # Not used in configuration file

    attr_reader :client_name

    # Supported environment variables:
    #
    # +NETSOUL_SERVER_HOST+: Netsoul server host, default 'ns-server.epita.fr'
    # +NETSOUL_SERVER_PORT+: Netsoul server port, default 4242
    # +NETSOUL_LOGIN+: IONIS account name
    # +NETSOUL_SOCKS_PASSWORD+: IONIS socks password
    # +NETSOUL_UNIX_PASSWORD+: IONIS unix password
    # +NETSOUL_AUTH_METHOD+: Authentication method, default :std. Valid options are => @see +Config::AUTH_METHODS+
    # +NETSOUL_STATE+: User status, default is :none. Valid options are => @see +Config::USER_STATES+
    # +NETSOUL_LOCATION+: User location is free text of your position. If you ar in IONIS network an automatic mapping is proceed to detect your location
    # +NETSOUL_USER_GROUP+: Free text specifying your promo or whatever else
    # +NETSOUL_CLIENT_NAME+: Redefine the client name exposed to the Netsoul server
    #
    # rubocop:disable all
    def initialize(opts = {})
      @server_host = ENV['NETSOUL_SERVER_HOST'] || opts.fetch(:server_host, 'ns-server.epita.fr')
      @server_port = Integer(ENV['NETSOUL_SERVER_PORT'] || opts.fetch(:server_port, 4242))
      @login = ENV['NETSOUL_LOGIN'] || opts.fetch(:login, 'ionis')
      @socks_password = ENV['NETSOUL_SOCKS_PASSWORD'] || opts.fetch(:socks_password, 'socks_password')
      @unix_password = ENV['NETSOUL_UNIX_PASSWORD'] || opts.fetch(:unix_password, 'unix_password')
      @auth_method = (ENV['NETSOUL_AUTH_METHOD'] || (AUTH_METHODS.include?(opts[:auth_method]) ? opts[:auth_method] : :std)).to_sym
      @state = (ENV['NETSOUL_STATE'] || (USER_STATES.include?(opts[:state]) ? opts[:state] : :none)).to_sym
      @location = ENV['NETSOUL_LOCATION'] || opts.fetch(:location, 'Home')
      @user_group = ENV['NETSOUL_USER_GROUP'] || opts.fetch(:user_group, 'ETNA_2008')
      @user_connection_info = {}

      @client_name = ENV['NETSOUL_CLIENT_NAME'] || opts.fetch(:client_name, "(Netsoul-Ruby v#{Netsoul::VERSION}) -> { Christian Kakesa, since 2009}")
    end
    # rubocop:enable all

    def build_user_connection_info(opts = {})
      return unless opts.is_a?(Hash)
      opts.each { |k, v| @user_connection_info[k] = v if VALID_USER_CONNECTION_INFO.include?(k) }
    end
  end
end
