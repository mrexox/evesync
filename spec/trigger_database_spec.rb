require_relative 'spec_helper'
require 'sysmoon/trigger/database'
require 'sysmoon/ipc/data/package'

module Sysmoon

  describe Trigger::Database do
    let (:db) { Trigger::Database.allocate }

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
  end
end
