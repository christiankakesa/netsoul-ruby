require 'spec_helper'

describe Netsoul do
  it 'Netsoul has a version number' do
    expect(Netsoul::VERSION).not_to be nil
  end

  # describe 'Tests LogTribe instance without @tag_name' do
  #   let! :logger do
  #     LogTribe::Loggers.new(::Logger.new(STDOUT))
  #   end
  #
  #   it 'create a non null LogTribe#loggers instance' do
  #     expect(logger).not_to be nil
  #   end
  #
  #   it '@tag_name must be nil' do
  #     expect(logger.tag_name).to be nil
  #   end
  #
  #   it 'set a specific @level' do
  #     expect(logger.level).to eq(::Logger::DEBUG)
  #     logger.level = ::Logger::INFO
  #     expect(logger.level).to eq(::Logger::INFO)
  #     logger.loggers.each do |l|
  #       expect(l.level).to eq(::Logger::INFO) if l.respond_to?(:level)
  #     end
  #   end
  #
  #   it 'set a specific @progname' do
  #     expect(logger.progname).to be nil
  #     progname_ = 'log_tribe_program'
  #     logger.progname = progname_
  #     expect(logger.progname).to eq(progname_)
  #     logger.loggers.each do |l|
  #       expect(l.progname).to eq(progname_) if l.respond_to?(:progname)
  #     end
  #   end
  #
  #   it 'set a specific @datetime_format' do
  #     expect(logger.datetime_format).to be nil
  #     datetime_format_ = '%Y-%m-%dT%H:%M:%S+%:z'
  #     logger.datetime_format = datetime_format_
  #     expect(logger.datetime_format).to eq(datetime_format_)
  #     logger.loggers.each do |l|
  #       expect(l.datetime_format).to eq(datetime_format_) if l.respond_to?(:datetime_format)
  #     end
  #   end
  #
  #   it 'set a specific @formatter' do
  #     expect(logger.formatter).to be nil
  #     formatter_proc_ = proc { |severity, datetime, _progname, msg| "#{severity} [#{datetime}]: #{msg}\n" }
  #     logger.formatter = formatter_proc_
  #     expect(logger.formatter).to eq(formatter_proc_)
  #     logger.loggers.each do |l|
  #       expect(l.formatter).to eq(formatter_proc_) if l.respond_to?(:formatter)
  #     end
  #   end
  #
  #   it '@default_formatter must be an instance of ::Logger::Formatter' do
  #     expect(logger.default_formatter).to be_a(::Logger::Formatter)
  #   end
  #
  #   it 'reasonably test a #add wrapper method through logger#info severity' do
  #     console_ = StringIO.new
  #     logger_ = LogTribe::Loggers.new([::Logger.new(console_), Fluent::Logger::MockFluentLogger.new(console_)])
  #     expect { logger_.info 'This this a message' }.not_to raise_error(Exception)
  #   end
  #
  #   it 'reasonably test a #<< wrapper method (raw logging)' do
  #     console_ = StringIO.new
  #     logger_ = LogTribe::Loggers.new([::Logger.new(console_), Fluent::Logger::MockFluentLogger.new(console_)])
  #     expect { logger_ << 'This this a message' }.not_to raise_error(Exception)
  #   end
  #
  #   it 'reasonably test a #close wrapper method' do
  #     logger_ = LogTribe::Loggers.new(::Logger.new(StringIO.new))
  #     expect { logger_.close }.not_to raise_error(Exception) if logger_.respond_to?(:close)
  #   end
  # end

  # describe 'Tests LogTribe instance with "tag_name"' do
  #   let! :tag_name do
  #     'test_tag'
  #   end
  #
  #   let! :logger_tag do
  #     LogTribe::Loggers.new(::Logger.new(STDOUT), tag_name: tag_name)
  #   end
  #
  #   it 'create a non null LogTribe#loggers instance' do
  #     expect(logger_tag).not_to be nil
  #   end
  #
  #   it '@tag_name must be set' do
  #     expect(logger_tag.tag_name).to eq(tag_name)
  #   end
  # end
end
