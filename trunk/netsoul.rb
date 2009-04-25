=begin
	Made by Christian KAKESA etna_2008(paris) <christian.kakesa@gmail.com>
=end

begin
  require 'socket'
  require 'base64'
  require 'uri'
  require 'digest/md5'
rescue LoadError
  puts "Error: #{$!}"
  exit
end

module NetSoul

  class Error < StandardError; end

  class NetSoul
    include Singleton

    attr_reader :connection_values, :sock

    def initialize(config_hash) #TODO : describe the config hash array.
      @config = config_hash
      @connection_values = Hash.new
      @sock = nil
    end

    def connect
      @sock = TCPSocket.new(@config.conf[:server_host].to_s, @config.conf[:server_port].to_i)
      if not @sock #TODO : raise an error
        return false
      end
      buf = sock_get()
      cmd, socket_num, md5_hash, client_ip, client_port, server_timestamp = buf.split
      server_timestamp_diff = Time.now.to_i - server_timestamp.to_i
      @connection_values[:md5_hash] = md5_hash
      @connection_values[:client_ip] = client_ip
      @connection_values[:client_port] = client_port
      @connection_values[:client_name] = @config.conf[:client_name]
      @connection_values[:login] = @config.conf[:login]
      @connection_values[:socks_password] = @config.conf[:socks_password]
      @connection_values[:unix_password] = @config.conf[:unix_password]
      @connection_values[:connection_type] = @config.conf[:connection_type]||"std"
      @connection_values[:state] = @config.conf[:state]
      @connection_values[:location] = @config.conf[:location]
      @connection_values[:user_group] = @config.conf[:user_group]
      @connection_values[:system] = RUBY_PLATFORM
      @connection_values[:timestamp_diff] = server_timestamp_diff
      auth()
    end

    def auth
      sock_send("auth_ag ext_user none -")
      rep = sock_get()
      if not (rep.split(' ')[1] == "002") #TODO : raise an error
        return false
      end

      if (@connection_values[:connection_type].to_s == "krb5")
        sock_send(Message.kerberos_authentication(@connection_values))
      else
        sock_send(Message.standard_authentication(@connection_values))
      end

      rep = sock_get()
      if not (rep.split(' ')[1] == "002") #TODO : Here raise an error
        return false
      end
      sock_send("user_cmd attach")
      sock_send( Message.set_state(@connection_values[:state], get_server_timestamp()) )
    end

    def disconnect
      sock_send(Message.ns_exit())
      sock_close()
    end

    def sock_send(str)
      @sock.puts str.to_s.chomp
    end

    def sock_get()
      @sock.gets
    end

    def sock_close
      @sock.close rescue nil
    end

    def get_server_timestamp
      Time.now.to_i - @connection_values[:timestamp_diff].to_i
    end
  end

  class Message
    def self.standard_authentication(connection_values)
      auth_string = Digest::MD5.hexdigest('%s-%s/%s%s'%[	connection_values[:md5_hash],
      connection_values[:client_ip],
      connection_values[:client_port],
      connection_values[:socks_password]	])
      return 'ext_user_log %s %s %s %s'%[	connection_values[:login],
      auth_string,
      Message.escape(Location::get(connection_values[:client_ip]) == "ext" ? connection_values[:location] : Location::get(connection_values[:client_ip])),
    Message.escape(connection_values[:client_name])]
  end

  def self.kerberos_authentication(connection_values)
    begin
      require 'NsToken'
    rescue LoadError
      puts "Error: #{$!}"
      puts "Build the \"NsToken\" ruby/c extension if you don't.\nSomething like this : \"cd ./kerberos && ruby extconf.rb && make\""
      puts "Copy the builded extension in the same directory than the ruby-netsoul library."
      return
    end
    tk = NsToken.new
    if not tk.get_token(connection_values[:login], connection_values[:unix_password])
      puts "Impossible to retrieve the kerberos token !!!"
      return
    end
    return 'ext_user_klog %s %s %s %s %s'%[tk.token_base64.slice(0, 812), Message.escape(connection_values[:system]), Message.escape(connection_values[:location]), Message.escape(connection_values[:user_group]), Message.escape(connection_values[:client_name])]
  end

  def self.send_message(user, msg)
    return 'user_cmd msg_user %s msg %s'%[user, Message.escape(msg.to_s)]
  end

  def self.start_writing_to_user(user)
    return 'user_cmd msg_user %s dotnetSoul_UserTyping null'%[user]
  end

  def self.stop_writing_to_user(user)
    return 'user_cmd msg_user %s dotnetSoul_UserCancelledTyping null'%[user]
  end

  def self.list_users(user_list)
    return 'list_users {%s}'%[user_list]
  end

  def self.who_users(user_list)
    return 'user_cmd who {%s}'%[user_list]
  end

  def self.watch_users(user_list)
    return 'user_cmd watch_log_user {%s}'%[user_list]
  end

  def self.set_state(state, timestamp)
    return 'user_cmd state %s:%s'%[state, timestamp]
  end

  def self.set_user_data(data)
    return 'user_cmd user_data %s'%[Message.escape(data.to_s)]
  end

  def self.xfer(user, id, filename, size, desc)
    return 'user_cmd msg_user %s desoul_ns_xfer %s'%[user.to_s, id.to_s, Message.escape(filename.to_s), size.to_s, Message.escape(desc.to_s)]
  end

  def self.desoul_ns_xfer(user, id, filename, size, desc)
    return 'user_cmd msg_user %s desoul_ns_xfer %s'%[user.to_s, Message.escape("#{id.to_s} #{filename.to_s} #{size.to_s} #{desc.to_s}")]
  end

  def self.xfer_accept(user, id)
    return 'user_cmd msg_user %s desoul_ns_xfer_accept %s'%[user.to_s, id.to_s]
  end

  def self.desoul_ns_xfer_accept(id)
    return 'user_cmd msg_user %s desoul_ns_xfer_accept %s'%[user.to_s, id.to_s]
  end

  def self.xfer_data(id, data)
    return 'user_cmd msg_user %s desoul_ns_xfer_data %s'%[user.to_s, Message.escape("#{id.to_s} #{Base64.b64encode(data.to_s, data.to_s.length)}")]
  end

  def self.desoul_ns_xfer_data(id, data)
    return 'user_cmd msg_user %s desoul_ns_xfer_data %s'%[user.to_s, Message.escape("#{id.to_s} #{Base64.b64encode(data.to_s, data.to_s.length)}")]
  end

  def self.xfer_cancel(user, id)
    return 'user_cmd msg_user %s desoul_ns_xfer_cancel %s'%[user.to_s, id.to_s]
  end

  def self.desoul_ns_xfer_cancel(id)
    return 'user_cmd msg_user %s desoul_ns_xfer_cancel %s'%[user.to_s, id.to_s]
  end

  def self.ping
    return "ping 42"
  end

  def self.ns_exit
    return "exit"
  end

  def self.escape(str)
    str = URI.escape(str, Regexp.new("#{URI::PATTERN::ALNUM}[:graph:][:punct:][:cntrl:][:print:][:blank:]", false, 'N'))
    str = URI.escape(str, Regexp.new("[^#{URI::PATTERN::ALNUM}]", false, 'N'))
    return str
  end

  def self.unescape(str)
    str = URI.unescape(str)
    return str
  end

  def self.ltrim(str)
    return str.to_s.gsub(/^\s+/, '')
  end

  def self.rtrim(str)
    return str.to_s.gsub(/\s+$/, '')
  end

  def self.trim(str)
    str = Message.ltrim(str.to_s)
    str = Message.rtrim(str.to_s)
    return str
  end
end

class Location
  def self.get(ip)
    data = {	"lab-cisco-mid-sr"	=> "10.251.",
      "etna"			=> "10.245.",
      "lse"			=> "10.227.42.",
      "sda"			=> "10.227.4.",
      "lab"			=> "10.227.",
      "lab-tcom"		=> "10.226.7.",
      "lab-acu"		=> "10.226.6.",
      "lab-console"		=> "10.226.5.",
      "lab-mspe"		=> "10.226.",
      "epitanim"		=> "10.225.19.",
      "epidemic"		=> "10.225.18.",
      "sda"			=> "10.225.10.",
      "cycom"			=> "10.225.8.",
      "epx"			=> "10.225.7.",
      "prologin"		=> "10.225.6.",
      "nomad"			=> "10.225.2.",
      "assos"			=> "10.225.",
      "sda"			=> "10.224.14.",
      "www"			=> "10.223.106.",
      "episport"		=> "10.223.104.",
      "epicom"		=> "10.223.103.",
      "bde-epita"		=> "10.223.100.",
      "omatis"		=> "10.223.42.",
      "ipsa"			=> "10.223.15.",
      "lrde"			=> "10.223.13.",
      "cvi"			=> "10.223.7.",
      "epi"			=> "10.223.1.",
      "pasteur"		=> "10.223.",
      "bocal"			=> "10.42.42.",
      "sm"			=> "10.42.",
      "vpn"			=> "10.10.",
      "adm"			=> "10.1.",
    "epita"			=> "10."	}
    data.each do |key, val|
      res = ip.match(/^#{val}/)
      if res
        res = "#{key}".chomp
        return res
      end
    end
    return "ext"
  end
end

end

