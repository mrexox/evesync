# TODO: write package-related classes and functions
require 'sysmoon/package'

class RhelPackageWatcher

  def initialize(queue)
    @queue = queue
  end

  def run
    loop do
      sleep 5
      @queue << Package.new(
        name: 'unknown',
        version: '0.0.0'
      )
    end
  end
end
