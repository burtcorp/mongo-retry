require 'mongo'

module Mongo
  class Retry
    DEFAULT_RETRY_SLEEPS = [1, 5, 10].freeze
    DEFAULT_RETRYABLE_EXCEPTIONS = [
      ::Mongo::ConnectionError,
      ::Mongo::ConnectionTimeoutError,
      ::Mongo::ConnectionFailure,
      ::Mongo::OperationTimeout
    ]

    DEFAULT_OPTIONS = {
      delayer: Kernel.method(:sleep),
      retries: DEFAULT_RETRY_SLEEPS,
      exceptions: DEFAULT_RETRYABLE_EXCEPTIONS,
      retry_exceptions: DEFAULT_RETRYABLE_EXCEPTIONS,
      logger: nil
    }

    def initialize(connection, options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @connection = connection
    end

    def connection_guard(retries = @options[:retries].dup)
      yield
    rescue *@options[:exceptions] => e
      if retry_timeout = retries.pop
        log(:retry, e)
        @options[:delayer].call(retry_timeout)
        refresh!
        retry
      else
        log(:fail, e)
        raise e
      end
    end

    private

    def log(reason, exception)
      if @options[:logger]
        @options[:logger].call(reason, exception)
      end
    end

    def refresh!
      @connection.refresh
    rescue *@options[:retry_exceptions] => e
      log(:refresh, e)
    end
  end
end
