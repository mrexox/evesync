
module Sysmoon
  module Utils

    def self.local_ip?(ip)
      ips = `getent hosts #{ip}`
              .lines
              .map(&:split)
              .map(&:first)
      local_ips = `ip a`
                    .lines
                    .grep(/inet/)
                    .map(&:split)
                    .map { |lines| lines[1].split('/')[0] }

      not (ips & local_ips).empty?
    end

  end
end

# For ruby < 2.1
class Array
  unless defined? to_h
    def to_h
      Hash[*self.flatten(1)]
    end
  end
end
