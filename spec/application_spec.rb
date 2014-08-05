require 'spec_helper'
describe CrapServer::Application do
  before do
    # Reset to nil the configuration
    CrapServer::Application.class_eval do
      @config = nil
    end
    # Reset the logger to nil
    CrapServer::Application.class_eval do
      @logger = Dummy
    end
  end
  context 'run!' do

    it 'should accept a block' do
      expect(CrapServer::Application.method(:run!).parameters[-1][0]).to eq(:block)
    end

    context 'without loop' do
      before do
        # We don't want to block the specs because the sockets
        allow(Socket).to receive(:accept_loop).and_return(nil)
        allow(Socket).to receive(:new) do |*args|
          Dummy
        end
      end

      it 'should bind IPv4 and IPv6' do
        @v4 = false
        @v6 = false
        allow(Socket).to receive(:new) do |*args|
          @v4 = true if args[0] == :INET and args[1] == :STREAM and args.size == 2
          @v6 = true if args[0] == :INET and args[1] == :STREAM and args.size == 2
          Dummy
        end
        CrapServer::Application.run! do
        end
        expect(@v4).to eq(true)
        expect(@v6).to eq(true)
      end

      it 'if the user does not configure the app, should start the default configuration' do
        expect(CrapServer::Configure).to receive(:new) do
          Dummy
        end
        CrapServer::Application.run! do
        end
      end

      it 'should bump to the maximum allowed opened files' do
        expect(Process).to receive(:setrlimit).with(:NOFILE, Process.getrlimit(:NOFILE)[1])
        CrapServer::Application.run! do
        end
      end
    end

  end
end