require 'base64'
require 'digest/md5'
require 'uri'

module Netsoul
  class Message
    class << self
      def _standard_auth_string(c)
        str = c.user_connection_info[:md5_hash]
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

      # :nocov:
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
      # :nocov:

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
        "user_cmd msg_user #{user} xfer_data #{Message._escape("#{id} #{Base64.encode64(data.to_s)}")}"
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

  class Location
    class << self
      def get(ip)
        locations.each do |key, val|
          return key.to_s if ip =~ /^#{val}/
        end
        'ext'.freeze
      end

      # rubocop:disable all
      def locations
        @locations ||= {
            :'lab-cisco-mid-sr' => '10.251.'.freeze,
            etna: '10.245.'.freeze,
            lse: '10.227.42.'.freeze,
            :'sda-1' => '10.227.4.'.freeze,
            lab: '10.227.'.freeze,
            :'lab-tcom' => '10.226.7.'.freeze,
            :'lab-acu' => '10.226.6.'.freeze,
            :'lab-console' => '10.226.5.'.freeze,
            :'lab-mspe' => '10.226.'.freeze,
            epitanim: '10.225.19.'.freeze,
            epidemic: '10.225.18.'.freeze,
            :'sda-2' => '10.225.10.'.freeze,
            cycom: '10.225.8.'.freeze,
            epx: '10.225.7.'.freeze,
            prologin: '10.225.6.'.freeze,
            nomad: '10.225.2.'.freeze,
            assos: '10.225.'.freeze,
            sda: '10.224.14.'.freeze,
            www: '10.223.106.'.freeze,
            episport: '10.223.104.'.freeze,
            epicom: '10.223.103.'.freeze,
            :'bde-epita' => '10.223.100.'.freeze,
            omatis: '10.223.42.'.freeze,
            ipsa: '10.223.15.'.freeze,
            lrde: '10.223.13.'.freeze,
            cvi: '10.223.7.'.freeze,
            epi: '10.223.1.'.freeze,
            pasteur: '10.223.'.freeze,
            bocal: '10.42.42.'.freeze,
            sm: '10.42.'.freeze,
            vpn: '10.10.'.freeze,
            adm: '10.1.'.freeze,
            epita: '10.'.freeze
        }
      end
    end
  end
end
