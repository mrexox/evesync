require_relative 'spec_helper'
require 'evesync/utils'
require 'evesync/discover'

module Evesync
  describe Discover do
    let(:discovery) { Discover.allocate }
    let(:evesync) { double('IPC::Client of evesync') }
    let(:socket) { double('Listen socket') }
    let(:pack) do
      {
        evesync: {
          message: Discover::DISCOVERY_REQ,
          os: 'rhel',
        }
      }.to_json
    end

    context 'fine behaviour' do
      it 'should add node ip to known' do
        discovery.instance_variable_set(:@listen_sock, socket)
        discovery.instance_variable_set(:@evesync, evesync)

        expect(discovery).to receive(:loop).and_yield

        expect(socket).to receive(:recvfrom).and_return([pack, ['ip']])

        expect(Utils).to receive(:local_ip?).and_return(false)

        expect(evesync).to receive(:add_remote_node).with('ip')

        expect(discovery).to receive(:send_discovery_message)
                               .with('ip', Discover::DISCOVERY_ANS)

        discovery.send(:listen_discovery)
      end
    end
  end
end
