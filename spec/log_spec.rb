require_relative 'spec_helper'
require 'evesync/log'

module Evesync
  describe Log do
    it 'should normally call log' do
      %i[debug info notice warn error fatal].each do |level|
        expect(Log.send(level, "#{level} message")).to eq(nil)
      end
    end
  end
end
