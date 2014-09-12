# Simple retry error handling on connection errors in for the [Mongo ruby driver](https://github.com/mongodb/mongo-ruby-driver)

In its simplest form
```ruby
require 'mongo'
require 'mongo-retry'

client = Mongo::MongoClient.new
retryer = MongoRetry.new(client)

doc = retryer.connection_guard { # Will retry after 1, 5, 10 seconds
  client.db('foo')['bar'].find_one()
}

```

You may also specify the following optional parameters here with the default values in place.

```ruby

retryer = MongoRetry.new(client,  delayer: Kernel.method(:sleep),
    retries: DEFAULT_RETRY_SLEEPS,  # [1, 5, 10]
    exceptions: DEFAULT_RETRYABLE_EXCEPTIONS, # [::Mongo::ConnectionError,::Mongo::ConnectionTimeoutError,::Mongo::ConnectionFailure,::Mongo::OperationTimeout]
    retry_exceptions: DEFAULT_RETRYABLE_EXCEPTIONS, # [::Mongo::ConnectionError,::Mongo::ConnectionTimeoutError,::Mongo::ConnectionFailure,::Mongo::OperationTimeout]
    logger: nil)

```

## A note on logger

logger should be a lambda with two arguments

```ruby
logger = lambda { |reason, e|
  # Where reason may be :retry, :fail, :reconnect_fail
  p reason
  p e
}
```

In the default case where mongo would be down the following is expected to be received by the logger

```ruby

doc = retryer.connection_guard {
  client.db('foo')['bar'].find_one()
}
# Would be identical have the same effect in respect to the logger as
logger.call(:retry, exception)
logger.call(:reconnect_fail, exception)
logger.call(:retry, exception)
logger.call(:reconnect_fail, exception)
logger.call(:retry, exception)
logger.call(:reconnect_fail, exception)
logger.call(:fail, exception)

```
