# TODO: add logging
require_relative './rpm'

class RhelPackageWatcher
  def initialize(queue)
    @queue = queue
    @rpm_packages = Rpm.new
  end

  def run
    loop do
      sleep 10 # FIXME: don't use magic numbers
      @rpm_packages.changes.each do |pkg|
        @queue << pkg
      end
    end
  end
end
