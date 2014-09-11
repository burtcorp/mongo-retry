class MongoRetry


  RETRY_SLEEPS = [1, 5, 10].freeze
  RETRYABLE_EXCEPTIONS = [
    ::Mongo::ConnectionError,
    ::Mongo::ConnectionTimeoutError,
    ::Mongo::ConnectionFailure,
    ::Mongo::OperationTimeout
  ]

  def initialize(connection, logger = nil, delayer = Kernel.method(:sleep))
    @connection = connection
    @delayer = delayer
    @logger = logger || proc {}
  end

  def connection_guard(retries = RETRY_SLEEPS.dup)
    yield
  rescue *RETRYABLE_EXCEPTIONS => e
    if retry_timeout = retries.pop
      log(:retry, e)
      @delayer.call(retry_timeout)
      reconnect!
      retry
    else
      log(:fail, e)
      raise e
    end
  end

  private

  def log(reason, exception)
    if @logger
      @logger.call(reason, exception)
    end
  end

  def reconnect!
    @connection.reconnect
  rescue *RETRYABLE_EXCEPTIONS => e
    # Mongo ruby driver fails sometimes on handover, screw that...
    log(:reconnect_fail, e)
  end
end
