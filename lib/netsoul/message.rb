require 'base64'
require 'digest/md5'
require 'uri'

require_relative 'location'

module Netsoul
  class Message
    class << self
      def _standard_auth_string(c)
        str = "#{c.user_connection_info[:md5_hash]}"
        str << "-#{c.user_connection_info[:client_ip]}"
        str << "/#{c.user_connection_info[:client_port]}#{c.socks_password}"
        Digest::MD5.hexdigest(str)
      end

      def standard_auth(config)
        client_ip = config.user_connection_info[:client_ip]
        location = Message._escape(Location.get(client_ip) == 'ext'.freeze ? config.location : Location.get(client_ip))
        client_name = Message._escape(config.client_name)
        "ext_user_log #{config.login} #{_standard_auth_string(config)} #{client_name} #{location}"
      end

      def _kerberos_get
        @netsoul_kerberos ||= NetsoulKerberos.new
      rescue LoadError => e
        raise Netsoul::Error, "NetsoulKerberos library not found: #{e}.".freeze
      end

      def _kerberos_auth_klog(config)
        location = Message._escape(config.location)
        user_group = Message._escape(config.user_group)
        client_name = Message._escape(config.client_name)
        "ext_user_klog #{_kerberos_get.token_base64.slice(0, 812)} #{Message._escape(RUBY_PLATFORM)} #{location} #{user_group} #{client_name}"
      end

      def kerberos_auth(config)
        require 'netsoul_kerberos'

        unless _kerberos_get.build_token(config.login, config.unix_password)
          fail Netsoul::Error, 'Impossible to retrieve the kerberos token.'.freeze
        end
        _kerberos_auth_klog(config)
      end

      def auth_ag
        'auth_ag ext_user none none'.freeze
      end

      def send_message(user, msg)
        "user_cmd msg_user #{user} msg #{Message._escape(msg.to_s)}"
      end

      def start_writing_to_user(user)
        "user_cmd msg_user #{user} dotnetSoul_UserTyping null"
      end

      def stop_writing_to_user(user)
        "user_cmd msg_user #{user} dotnetSoul_UserCancelledTyping null"
      end

      def list_users(user_list)
        "list_users {#{user_list}}"
      end

      def who_users(user_list)
        "user_cmd who {#{user_list}}"
      end

      def watch_users(user_list)
        "user_cmd watch_log_user {#{user_list}}"
      end

      def attach
        'user_cmd attach'.freeze
      end

      def user_state(state, timestamp)
        "user_cmd state #{state}:#{timestamp}"
      end

      def user_data(data)
        "user_cmd user_data #{Message._escape(data.to_s)}"
      end

      def xfer(user, id, filename, size, desc)
        "user_cmd msg_user #{user} xfer #{Message._escape("#{id} #{filename} #{size} #{desc}")}"
      end

      def xfer_accept(user, id)
        "user_cmd msg_user #{user} xfer_accept #{id}"
      end

      def xfer_data(user, id, data)
        "user_cmd msg_user #{user} xfer_data #{Message._escape("#{id} #{Base64.b64encode(data.to_s, data.to_s.length)}")}"
      end

      def xfer_cancel(user, id)
        "user_cmd msg_user #{user} xfer_cancel #{id}"
      end

      def ping
        'pong'.freeze
      end

      def ns_exit
        'exit'.freeze
      end

      def _escape(str)
        str = URI.escape(str, Regexp.new("#{URI::PATTERN::ALNUM}[:graph:][:punct:][:cntrl:][:print:][:blank:]", false, 'N'.freeze))
        URI.escape(str, Regexp.new("[^#{URI::PATTERN::ALNUM}]", false, 'N'.freeze))
      end

      def _unescape(str)
        URI.unescape str
      end
    end
  end
end
