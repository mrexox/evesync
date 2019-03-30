require_relative 'spec_helper'
require 'sysmoon/utils'
require 'sysmoon/sync'

module Sysmoon
  describe Discovery do
    let (:discovery) { Discovery.allocate }
    let (:sysmoon) { double('IPC::Client of sysmoon') }
    let (:socket) { double('Listen socket') }

    context 'fine behaviour' do
      it 'should add node ip to known' do
        discovery.instance_variable_set(:@listen_sock, socket)
        discovery.instance_variable_set(:@sysmoon, sysmoon)
        expect(discovery).to receive(:loop).and_yield
        expect(socket).to receive(:recvfrom)
                            .and_return([Discovery::DISCOVERY_REQ, ['ip']])
        expect(Utils).to receive(:local_ip?).and_return(false)

        expect(sysmoon).to receive(:add_remote_node).with('ip')
        expect(discovery).to receive(:send_discovery_message)
                               .with('ip', Discovery::DISCOVERY_ANS)
        discovery.send(:listen_discovery)
      end
    end
  end
end
