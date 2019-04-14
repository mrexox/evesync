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
          local: { 'package' => %w(1 2 3) },
          remote: { 'n1' => {'package' => %w(1 2 3 4)} }
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

        expect(diff).to include('package')
        expect(diff['package']).to include('4')
        expect(diff['package']['4']).to match_array(%w(n1))
        expect(diff['package']).not_to include('1','2','3')
      end
    end

    context 'a bit complicated diff' do
      let(:params) do
        {
          local: {
            'package1' => %w(1 2 6),
            'package2' => %w(1 4),
            'file' => %w(1 5),
          },
          remote: {
            'n1' => {
              'package' => %w(1 2 3 4 5 6),
              'file' => %w(1 2 3 4 5 6),
            },
            'n2' => {
              'package' => %w(1 2 3 4),
              'package1' => %w(1 2 3 4 5 6),
              'package2' => %w(1 2 3 4 5 6 7),
            },
            'n3' => {           # Full
              'package' => %w(1 2 3 4),
              'package1' => %w(1 2 3 4 5 6),
              'package2' => %w(1 2 3 4 5 6 7),
            },

          }
        }
      end

      let(:v2) do
        {
          'package' => %w(1 2 3 4 5 6),
          'package1' => %w(1 2 3 4 5 6),
          'package2' => %w(1 2 3 4 5 6 7),
          'file' => %w(1 2 3 4 5 6),
        }
      end

      it 'should find the newer' do
        expect(syncer).to receive(:diff_missed)
                            .with({ v1: params[:local],
                                    v2: v2})
                            .and_call_original

        diff = syncer.send(:events_diff, params)

        expect(diff).to include('package', 'package2', 'file')
        expect(diff).not_to include('package1')

        expect(diff['package']).to include('1','2','3','4','5','6')
        expect(diff['package2']).to include('5', '6', '7')
        expect(diff['package2']).not_to include('1', '2', '3', '4')
        expect(diff['file']).to include('6')
        expect(diff['file']).not_to include('1', '2', '3', '4', '5')
      end

    end
  end
end
