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
    config.build_user_connection_info(md5_hash: 'adv', client_ip: '4.2.4.2', client_port: '42', not_exist: false)
    expect(config.user_connection_info.size).to eq(Netsoul::Config::VALID_USER_CONNECTION_INFO.size)

    expect(config.client_name).not_to be_nil
    expect(config.client_name).to be_a(String)
  end
end
