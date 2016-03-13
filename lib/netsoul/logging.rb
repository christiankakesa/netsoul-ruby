# frozen_string_literal: true

require 'logger'

module Netsoul
  module Logging # :nodoc:
    PREFIX = '[Netsoul-Ruby]'.freeze

    class << self
      attr_writer :logger
    end

    def self.logger
      @logger ||= ::Logger.new(STDERR).tap do |logger|
        logger.level = Logger::INFO
        logger.formatter = proc do |severity, datetime, _progname, msg|
          "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%L'.freeze)}] #{msg}\n"
        end
      end
    end

    private

    def log(level, message)
      Netsoul::Logging.logger.send(level.to_sym, "#{PREFIX} #{message}") if Netsoul::Logging.logger
    end
  end
end
