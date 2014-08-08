require 'spec_helper'

describe CrapServer::ThreadPool do
  context 'run' do
    before do
      allow_any_instance_of(CrapServer::ThreadPool).to receive(:spawn_thread).and_return(true)
      allow(ThreadGroup).to receive(:new).and_return(Dummy)
      allow_any_instance_of(CrapServer::ThreadPool).to receive(:sleep).and_return(true)
    end
    it 'should abort on exception' do
      pool = CrapServer::ThreadPool.new([Dummy, Dummy])
      expect(Thread).to receive(:abort_on_exception=).with(true)
      pool.run do
      end
    end

    it 'should spawn pool_size thread' do
      pool = CrapServer::ThreadPool.new([Dummy, Dummy])
      size = rand(2..20) # We make sure that is a random number and is not a selected test :P
      CrapServer::Application.configure do |c|
        c.pool_size = size
      end
      expect_any_instance_of(CrapServer::ThreadPool).to receive(:spawn_thread).exactly(size).times()
      pool.run do
      end
    end
  end

  context 'spawn_thread' do
    it 'should spawn a new thread' do
      expect(Thread).to receive(:new).and_return(true)
      pool = CrapServer::ThreadPool.new([Dummy, Dummy])
      pool.send(:spawn_thread)
    end
  end
end