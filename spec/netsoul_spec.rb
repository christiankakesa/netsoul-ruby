# frozen_string_literal: false

require 'spec_helper'

describe Netsoul do
  it 'have a version number' do
    expect(Netsoul::VERSION).not_to be nil
  end

  it 'Logger works with composition paradigm' do
    class LogOlder
      include Netsoul::Logging

      def out
        log(:info, 'Amazing log string.'.freeze)
      end
    end

    expect { LogOlder.new.out }.not_to raise_error(Exception)
  end

  it 'Location gives the IONIS internal location or "ext"' do
    expect(Netsoul::Location.get('not exist IP'.freeze)).to eq('ext'.freeze)
    expect(Netsoul::Location.get('10.245.42.42'.freeze)).to eq('etna'.freeze)
  end

  it 'Config have a default values set' do
    config = Netsoul::Config.new

    expect(config.server_host).not_to be_nil
    expect(config.server_host).to be_a(String)

    expect(config.server_port).not_to be_nil
    expect(config.server_port).to be_an(Integer)

    expect(config.login).not_to be_nil
    expect(config.login).to be_a(String)

    expect(config.socks_password).not_to be_nil
    expect(config.socks_password).to be_a(String)

    expect(config.unix_password).not_to be_nil
    expect(config.unix_password).to be_a(String)

    expect(config.auth_method).not_to be_nil
    expect(config.auth_method).to be_a(Symbol)

    expect(config.state).not_to be_nil
    expect(config.state).to be_a(Symbol)

    expect(config.location).not_to be_nil
    expect(config.location).to be_a(String)

    expect(config.user_group).not_to be_nil
    expect(config.user_group).to be_a(String)

    expect(config.user_connection_info).not_to be_nil
    expect(config.user_connection_info).to be_a(Hash)
    config.build_user_connection_info
    expect(config.user_connection_info.empty?).to be_truthy
    config.build_user_connection_info(nil)
    expect(config.user_connection_info.empty?).to be_truthy
    config.build_user_connection_info(md5_hash: 'adv'.freeze, client_ip: '4.2.4.2'.freeze, client_port: '42'.freeze, not_exist: false)
    expect(config.user_connection_info.size).to eq(Netsoul::Config::VALID_USER_CONNECTION_INFO.size)

    expect(config.client_name).not_to be_nil
    expect(config.client_name).to be_a(String)
  end

  describe 'Message handling' do
    it 'returns standard_auth message' do
      c = Netsoul::Config.new
      c.build_user_connection_info md5_hash: 'hashx02hash'.freeze, client_ip: '4.2.4.2'.freeze, client_port: 4242
      standard_auth = Netsoul::Message.standard_auth(c)
      expect(standard_auth).not_to be_nil
      expect(standard_auth.to_s.size).to be > 0
    end

    it 'returns kerberos_auth message' do
      c = Netsoul::Config.new auth_method: :krb5
      expect { Netsoul::Message.kerberos_auth(c) }.to raise_exception Netsoul::Error

      # FIXME(fenicks): EPITECH Kerberos server is probably not working!
      # If this authentication method is not removed, remove the :nocov: mark around 'Netsoul::Message.kerberos_auth'
    end

    it 'returns auth_ag message' do
      auth_ag = Netsoul::Message.auth_ag
      expect(auth_ag).not_to be_nil
      expect(auth_ag.to_s.size).to be > 0
    end

    it 'returns send_message message' do
      message = Netsoul::Message.send_message('user'.freeze, 'empty message'.freeze)
      expect(message).not_to be_nil
      expect(message.to_s.size).to be > 0
    end

    it 'returns start_writing_to_user message' do
      start_writing_to_user = Netsoul::Message.start_writing_to_user('user'.freeze)
      expect(start_writing_to_user).not_to be_nil
      expect(start_writing_to_user.to_s.size).to be > 0
    end

    it 'returns stop_writing_to_user message' do
      stop_writing_to_user = Netsoul::Message.stop_writing_to_user('user'.freeze)
      expect(stop_writing_to_user).not_to be_nil
      expect(stop_writing_to_user.to_s.size).to be > 0
    end

    it 'returns list_users message' do
      list_users = Netsoul::Message.list_users('user1, user2'.freeze)
      expect(list_users).not_to be_nil
      expect(list_users.to_s.size).to be > 0
    end

    it 'returns who_users message' do
      who_users = Netsoul::Message.who_users('user1, user2'.freeze)
      expect(who_users).not_to be_nil
      expect(who_users.to_s.size).to be > 0
    end

    it 'returns watch_users message' do
      watch_users = Netsoul::Message.watch_users('user1, user2'.freeze)
      expect(watch_users).not_to be_nil
      expect(watch_users.to_s.size).to be > 0
    end

    it 'returns attach message' do
      attach = Netsoul::Message.attach
      expect(attach).not_to be_nil
      expect(attach.to_s.size).to be > 0
    end

    it 'returns user_state message' do
      user_state = Netsoul::Message.user_state('none'.freeze, 145_286_978)
      expect(user_state).not_to be_nil
      expect(user_state.to_s.size).to be > 0
    end

    it 'returns user_data message' do
      user_data = Netsoul::Message.user_data('my data'.freeze)
      expect(user_data).not_to be_nil
      expect(user_data.to_s.size).to be > 0
    end

    it 'returns xfer message' do
      xfer = Netsoul::Message.xfer('user'.freeze, 42, 'my_file.txt'.freeze, 4025, 'empty description'.freeze)
      expect(xfer).not_to be_nil
      expect(xfer.to_s.size).to be > 0
    end

    it 'returns a xfer_accept message' do
      xfer_accept = Netsoul::Message.xfer_accept('user'.freeze, 42)
      expect(xfer_accept).not_to be_nil
      expect(xfer_accept.to_s.size).to be > 0
    end

    it 'returns a xfer_data message' do
      xfer_data = Netsoul::Message.xfer_data('user'.freeze, 42, 'my_data'.freeze)
      expect(xfer_data).not_to be_nil
      expect(xfer_data.to_s.size).to be > 0
    end

    it 'returns a xfer_cancel message' do
      xfer_cancel = Netsoul::Message.xfer_cancel('user'.freeze, 42)
      expect(xfer_cancel).not_to be_nil
      expect(xfer_cancel.to_s.size).to be > 0
    end

    it 'returns a ping response' do
      ping_response = Netsoul::Message.ping
      expect(ping_response).not_to be_nil
      expect(ping_response.to_s.size).to be > 0
    end

    it 'returns exit command' do
      expect('exit'.freeze).to eq(Netsoul::Message.ns_exit)
    end

    it 'escape/unescape string' do
      TEXT = 'text sample'.freeze
      escaped_str = Netsoul::Message._escape(TEXT)
      expect(TEXT).to eq(Netsoul::Message._unescape(escaped_str))
    end
  end
end
