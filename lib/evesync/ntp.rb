require 'net/ntp'
require 'evesync/config'

module Evesync
  module NTP

    def self.time
      Net::NTP.get(Config['ntp']).time
    end

    def self.timestamp
      time.to_f.to_s
    end

  end
end
