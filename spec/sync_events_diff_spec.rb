require_relative 'spec_helper'
require 'sysmoon/utils'
require 'sysmoon/sync'

module Sysmoon
  describe Sync do
    let(:syncer) { Sync.allocate }

    context 'empty diff' do
      let(:params) { {local: {}, remote: {}} }

      it 'should return empty hash' do
        diff = syncer.send(:events_diff, params)

        expect(diff).to eq({})
      end
    end

    context 'simple diff, 1 objects' do
      let(:params) do
        {
          local: { 'package' => ['1','2','3'] },
          remote: { 'n1' => {'package' => ['1','2','3','4']} }
        }
      end

      it 'should find the newer' do
        # Hardly bind this function call.
        # The interface should not change!
        expect(syncer).to receive(:diff_missed)
                            .with({ v1: params[:local],
                                    v2: params[:remote]['n1']})
                            .and_call_original

        diff = syncer.send(:events_diff, params)

        puts(diff)
        expect(diff).to include('package')
        expect(diff['package']).to include('4')
        expect(diff['package']['4']).to match_array(%w(n1))
        expect(diff['package']).not_to include('1','2','3')
      end
    end
  end
end
