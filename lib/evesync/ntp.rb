require 'net/ntp'
require 'evesync/log'
require 'evesync/config'

module Evesync
  module NTP

    def self.time
      begin
        Timeout.timeout(5) do
          Net::NTP.get(Config['ntp']).time
        end
      rescue Errno::ECONNREFUSED
        Log.warn('NTP not configured. Using local time for timestamps')
        Time.now
      rescue Timeout::Error
        Log.warn('NTP timeout. Using local time')
        Time.now
      end
    end

    def self.timestamp
      time.to_f.to_s
    end

  end
end
