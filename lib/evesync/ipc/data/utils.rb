Dir[File.dirname(__FILE__) + '/*.rb'].each do |file|
  require file unless file.include?(__FILE__)
end

module Evesync
  module IPC
    module Data
      def self.from_json(json)
        hash = JSON.parse(json)
        Class.new.extend(Unhashable).from_hash(hash)
      end
    end
  end
end
