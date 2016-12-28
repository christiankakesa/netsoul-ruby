# frozen_string_literal: true

require 'logger'
require_relative 'version'

module Netsoul
  module Logging # :nodoc:
    PREFIX = "[Netsoul-Ruby:v#{Netsoul::VERSION}]".freeze

    class << self
      attr_writer :logger
    end

    def self.logger
      @logger ||= ::Logger.new(STDOUT).tap do |logger|
        $stdout.sync = true
        logger.level = Logger::INFO
        logger.formatter = proc do |severity, datetime, _progname, msg|
          "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%L')}] #{msg}\n"
        end
      end
    end

    private

    def log(level, message)
      Netsoul::Logging.logger.send(level.to_sym, "#{PREFIX} #{message}") if Netsoul::Logging.logger
    end
  end
end
