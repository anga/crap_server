require 'spec_helper'

describe CrapServer::Forker do
  context 'run' do
    before do
      allow(Process).to receive(:wait).and_return(Dummy)
      allow(Process).to receive(:kill).and_return(Dummy)
    end

    it 'should accept a block' do
      expect(CrapServer::Forker.new(Dummy).method(:run).parameters[-1][1]).to eq(:block)
    end

    it 'should spawn one process per core' do
      forker = CrapServer::Forker.new(Dummy)
      cores = forker.send(:processor_count)
      expect(forker).to receive(:spawn_child).exactly(cores).times().and_return(Dummy)
      allow_any_instance_of(CrapServer::Forker).to receive(:check_children).and_return true
      forker.run do
      end
    end

    it 'if someone interrupt the application, we must kill our children' do
      forker = CrapServer::Forker.new([Dummy, Dummy])
      cores = forker.send(:processor_count)
      allow(forker).to receive(:spawn_child).and_return(true)
      allow_any_instance_of(CrapServer::Forker).to receive(:check_children).and_raise(Interrupt)
      expect(Process).to receive(:kill).exactly(cores).times().and_return(true)
      forker.run do
      end
    end
  end

  context 'spawn_child' do
    pending 'check how to '
  end
end