require 'spec_helper'
module Mongo
  describe Retry do
    let(:connection) { double('connection', reconnect: true, do_something: true) }
    let(:delayer) { double('delayer', delay: true) }
    let(:logger) { double('logger', log: true)}

    subject { described_class.new(connection, :logger => logger.method(:log), :delayer => delayer.method(:delay)) }

    [Exception, StandardError].each do |error|
      it "does not rescue #{error}" do
        allow(connection).to receive(:do_something).and_raise(error)
        expect do
          subject.connection_guard do
            connection.do_something
          end
        end.to raise_error(error)
        expect(connection).to have_received(:do_something).exactly(:once)
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
          allow(connection).to receive(:do_something).and_return(:foo)
          result = subject.connection_guard do
            connection.do_something
          end
          expect(result).to eq(:foo)
        end

        it "retries max 3 times in case of #{error}" do
          allow(connection).to receive(:do_something).and_raise(error)
          begin
            subject.connection_guard do
              connection.do_something
            end
          rescue error
          end
          expect(connection).to have_received(:do_something).exactly(4).times
        end

        it "raises error #{error}" do
          allow(connection).to receive(:do_something).and_raise(error)
          expect do
            subject.connection_guard do
              connection.do_something
            end
          end.to raise_error(error)
        end

        it 'reconnects in case of mongo error' do
          allow(connection).to receive(:reconnect).and_raise(error)
          allow(connection).to receive(:do_something).and_raise(error)
          begin
            subject.connection_guard do
              connection.do_something
            end
          rescue error
          end
          expect(connection).to have_received(:reconnect).exactly(3).times
        end

        it 'ignores mongo reconnect errors' do
          allow(connection).to receive(:reconnect).and_raise(error)
          allow(connection).to receive(:do_something).and_raise(error)
          begin
            subject.connection_guard do
              connection.do_something
            end
          rescue error
          end
          expect(connection).to have_received(:reconnect).exactly(3).times
        end

        it 'does not rescue non mongo errors when reconnecting' do
          allow(connection).to receive(:reconnect).and_raise(ArgumentError)
          allow(connection).to receive(:do_something).and_raise(error)
          begin
            subject.connection_guard do
              connection.do_something
            end
          rescue ArgumentError
          end
          expect(connection).to have_received(:reconnect)
        end

        it 'calls sleep in each retry with the correct value' do
          allow(connection).to receive(:do_something).and_raise(error)
          allow(connection).to receive(:do_something).and_raise(error)
          begin
            subject.connection_guard do
              connection.do_something
            end
          rescue error
          end
          expect(delayer).to have_received(:delay).once.with(1)
          expect(delayer).to have_received(:delay).once.with(5)
          expect(delayer).to have_received(:delay).once.with(10)
          expect(connection).to have_received(:reconnect).exactly(3).times
        end

        it 'logs each connection failure' do
          exception = error.new
          allow(connection).to receive(:do_something).and_raise(exception)
          begin
            subject.connection_guard do
              connection.do_something
            end
          rescue error
          end
          expect(logger).to have_received(:log).with(:retry, exception).exactly(3).times
          expect(logger).to have_received(:log).with(:fail, exception).exactly(:once)
        end

        it 'logs each reconnection failure' do
          exception = error.new
          allow(connection).to receive(:do_something).and_raise(exception)
          allow(connection).to receive(:reconnect).and_raise(exception)
          begin
            subject.connection_guard do
              connection.do_something
            end
          rescue error
          end
          expect(logger).to have_received(:log).with(:retry, exception).exactly(3).times
          expect(logger).to have_received(:log).with(:reconnect_fail, exception).exactly(3).times
        end
      end
    end
  end
end
