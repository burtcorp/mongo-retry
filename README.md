# Simple retry error handling on connection errors in for the [Mongo ruby driver](https://github.com/mongodb/mongo-ruby-driver)

[![Build Status](https://travis-ci.org/burtcorp/mongo-retry.png?branch=master)](https://travis-ci.org/burtcorp/mongo-retry)
[![Coverage Status](https://coveralls.io/repos/burtcorp/mongo-retry/badge.png)](https://coveralls.io/r/burtcorp/mongo-retry)

In its simplest form
```ruby
require 'mongo'
require 'mongo-retry'

client = Mongo::MongoClient.new
retryer = Mongo::Retry.new(client)

# Will retry after 1, 5, 10 seconds and eventually fail
# by throwing the exception thrown on the 4th attempt
doc = retryer.connection_guard { client.db('foo')['bar'].find_one() }

```

You may also specify the following optional parameters here with the default values in place.

```ruby

retryer = Mongo::Retry.new(client,  delayer: Kernel.method(:sleep),
    retries: DEFAULT_RETRY_SLEEPS,  # [1, 5, 10]
    exceptions: DEFAULT_RETRYABLE_EXCEPTIONS, # [::Mongo::ConnectionError,::Mongo::ConnectionTimeoutError,::Mongo::ConnectionFailure,::Mongo::OperationTimeout]
    retry_exceptions: DEFAULT_RETRYABLE_EXCEPTIONS, # [::Mongo::ConnectionError,::Mongo::ConnectionTimeoutError,::Mongo::ConnectionFailure,::Mongo::OperationTimeout]
    logger: nil)

```

## A note on logger

logger should be a lambda with two arguments

```ruby
logger = lambda { |reason, e|
  # Where reason may be :retry, :fail, :refresh
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
logger.call(:refresh, exception)
logger.call(:retry, exception)
logger.call(:refresh, exception)
logger.call(:retry, exception)
logger.call(:refresh, exception)
logger.call(:fail, exception)

```


(The MIT License)

Copyright (c) 2011 Burt

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
