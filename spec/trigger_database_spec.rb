require_relative 'spec_helper'
require 'lmdb'
require 'fileutils'
require 'sysmoon/trigger/database'
require 'sysmoon/ipc/data/package'

module Sysmoon

  describe Trigger::Database do
    let(:db) { Trigger::Database.allocate }

    context "empty db" do
      it "should add entry based on timestamp and name" do
        db.instance_variable_set(:@db, {})

        package = instance_double('Sysmoon::IPC::Data::Package')
        allow(package).to receive(:name)
                            .and_return('name')
        allow(package).to receive(:timestamp)
                            .and_return('timestamp')
        allow(package).to receive(:to_hash)
                            .and_return('hash')

        db.send(:db_add_entry, package)

        expect(db.instance_variable_get(:@db).keys)
          .to match_array(['timestamp_name'])
        expect(db.instance_variable_get(:@db).values)
          .to match_array(['"hash"'])

      end

      it "sould save a file" do
        file = instance_double('Sysmoon::IPC::Data::File')
        allow(file).to receive(:action).and_return('not delete')
        allow(file).to receive(:is_a?)
                         .with(IPC::Data::File)
                         .and_return(true)

        expect(db).to receive(:save_file)
        expect(db).to receive(:db_add_entry).with(file)
        db.save(file)
      end
    end

    context "real db" do
      before(:all) {
        FileUtils.mkdir_p 'tmp'
      }

      # after(:all) {
      #   FileUtils.rm_rf 'tmp'
      # }

      let(:message) {
        p = IPC::Data::Package.new(
          name: 'package',
          version: '0.0.1',
          command: IPC::Data::Package::Command::INSTALL)
        p.instance_variable_set(:@timestamp, '1')
        p
      }

      before(:each) {
        FileUtils.rm_f 'tmp/*'
        env = LMDB.new('tmp')
        db.instance_variable_set(:@db, env.database)
        db.save(message)
        # Changing timestamp but not an object
        message.instance_variable_set(:@timestamp, '2')
        db.save(message)
      }


      it 'should save 2 timestamps for 1 object' do
        events = db.events
        expect(events.values).to match_array [%w(1 2)]
        expect(events.keys).to match_array [message.name]
      end

    end
  end
end
