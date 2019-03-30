require_relative 'spec_helper'
require 'sysmoon/trigger/package'

module Sysmoon
  describe Trigger::Base do
    let (:trigger) { Trigger::Package.new({}) }
    let (:message) { double('IPC::Data::Package') }

    context 'no ignore packages' do
      it 'should send_to_remotes' do
        # Expecting
        expect(trigger).to receive(:send_to_remotes)
        expect(trigger).to receive(:ignore?)
        expect(trigger).to receive(:save_to_db) { true }
        expect(trigger.process(message)).to eq(true)
      end
    end

    context 'some ignoring packages' do
      let (:db) { double('Database') }
      let (:trigger) { Trigger::Package.new(:db => db) }

      it 'should unignore' do
        # Preparing
        allow(message).to receive(:is_a?)
                           .with(IPC::Data::Package)
                           .and_return(true)
        allow(message).to receive(:==).and_return(true)
        trigger.ignore(message)

        # Expecting
        expect(trigger).to receive(:unignore)
        expect(trigger.process(message)).to eq(false)
      end

      it 'should save message with db' do
        expect(trigger).to receive(:save_to_db)
                              .with(db, message)
                              .and_call_original
        expect(db).to receive(:save).with(message)

        # TODO: raise and catch exception
        trigger.process(message)
      end
    end
  end
end
