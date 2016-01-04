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

    # rubocop:disable Metrics/AbcSize
    def initialize(opts = {})
      @server_host = opts.fetch(:server_host, 'ns-server.epita.fr'.freeze)
      @server_port = Integer(opts.fetch(:server_port, 4242))
      @login = opts.fetch(:login, 'ionis'.freeze)
      @socks_password = opts.fetch(:socks_password, 'socks_password'.freeze)
      @unix_password = opts.fetch(:unix_password, 'unix_password'.freeze)
      @auth_method = AUTH_METHODS.include?(opts[:auth_method]) ? opts[:auth_method] : :std
      @state = USER_STATES.include?(opts[:state]) ? opts[:state] : :none
      @location = opts.fetch(:location, 'Home'.freeze)
      @user_group = opts.fetch(:user_group, 'ETNA_2008'.freeze)
      @user_connection_info = {}

      @client_name = opts.fetch(:client_name, '(Netsoul-Ruby) -> { Christian Kakesa, since 2009}'.freeze)
    end

    def build_user_connection_info(opts = {})
      return unless opts.is_a?(Hash)
      opts.each { |k, v| @user_connection_info[k] = v if VALID_USER_CONNECTION_INFO.include?(k) }
    end
  end
end
