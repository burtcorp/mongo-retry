require 'spec_helper'
describe MongoRetry do
  let(:connection) { double('connection') }
  let(:delayer) { double('delayer') }
  let(:logger) { double('logger')}

  before do
    connection.stub(:reconnect)
    delayer.stub(:delay)
    logger.stub(:log)
  end
  subject { described_class.new(connection, logger.method(:log), delayer.method(:delay)) }


  [Exception, StandardError].each do |error|
    it "does not rescue #{error}" do
      connection.should_receive(:do_something).exactly(:once).and_raise(error)
      expect do
        subject.connection_guard do
          connection.do_something
        end
      end.to raise_error(error)
    end
  end

  [
    ::Mongo::ConnectionError,
    ::Mongo::ConnectionTimeoutError,
    ::Mongo::ConnectionFailure,
    ::Mongo::OperationTimeout
  ].each do |error|
    describe error.name do

      it "returns the value if no error" do
        connection.should_receive(:do_something).and_return(:foo)
        subject.connection_guard do
          connection.do_something
        end.should == :foo
      end

      it "retries max 3 times in case of #{error}" do
        connection.should_receive(:do_something).exactly(4).times.and_raise(error)
        expect do
          subject.connection_guard do
            connection.do_something
          end
        end.to raise_error(error)
      end

      it 'reconnects in case of mongo error' do
        connection.should_receive(:reconnect).exactly(3).times
        connection.stub(:do_something).and_raise(error)
        expect do
          subject.connection_guard do
            connection.do_something
          end
        end.to raise_error(error)
      end

      it 'ignores mongo reconnect errors' do
        connection.should_receive(:reconnect).and_raise(error)
        connection.stub(:do_something).and_raise(error)
        expect do
          subject.connection_guard do
            connection.do_something
          end
        end.to raise_error(error)
      end

      it 'does not rescue non mongo errors when reconnecting' do
        connection.should_receive(:reconnect).and_raise(ArgumentError)
        connection.stub(:do_something).and_raise(error)
        expect do
          subject.connection_guard do
            connection.do_something
          end
        end.to raise_error(ArgumentError)
      end

      it 'calls sleep in each retry with the correct value' do
        connection.should_receive(:reconnect).and_raise(error)
        delayer.should_receive(:delay).once.with(1)
        delayer.should_receive(:delay).once.with(5)
        delayer.should_receive(:delay).once.with(10)
        connection.stub(:do_something).and_raise(error)
        expect do
          subject.connection_guard do
            connection.do_something
          end
        end.to raise_error(error)
      end

      it 'logs each connection failure' do
        exception = error.new
        logger.should_receive(:log).with(:retry, exception).exactly(3).times
        logger.should_receive(:log).with(:fail, exception).exactly(:once)
        connection.stub(:do_something).and_raise(exception)
        expect do
          subject.connection_guard do
            connection.do_something
          end
        end.to raise_error(error)
      end

      it 'logs each reconnection failure' do
        exception = error.new
        connection.stub(:do_something).and_raise(exception)
        connection.stub(:reconnect).and_raise(exception)
        logger.should_receive(:log).with(:retry, exception).exactly(3).times
        logger.should_receive(:log).with(:reconnect_fail, exception).exactly(3).times
        expect do
          subject.connection_guard do
            connection.do_something
          end
        end.to raise_error(error)
      end
    end
  end
end
