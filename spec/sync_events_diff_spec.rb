require_relative 'spec_helper'
require 'sysmoon/utils'
require 'sysmoon/sync'

module Sysmoon
  describe Sync do
    let(:syncer) { Sync.allocate }

    context 'empty diff' do
      let(:params) { {local: {}, remote: {}} }

      it 'should return empty hash' do

      end
    end

    context 'simple diff, 1 objects' do
      let(:params) {
        {
          local: {'package' => ['1','2','3']},
          remote: {'n1' => {'package' => ['1','2','3','4']}}
        }
      }

      it 'should find the newer' do
        diff = syncer.send(:events_diff, params)

        expect(diff).to include('package')
        expect(diff['package']).to include('4')
        expect(diff['package']['4']).to match_array(['n1'])
        expect(diff['package']).not_to include('1','2','3')
      end
    end
  end
end
