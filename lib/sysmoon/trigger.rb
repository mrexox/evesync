require 'sysmoon/config'
require 'sysmoon/trigger/file'
require 'sysmoon/trigger/package'
require 'sysmoon/ipc/client'
require 'sysmoon/utils'

module Sysmoon
  class Trigger
    def initialize(watcher_queue)
      @w_queue = watcher_queue

      @sysdatad = IPC::Client.new(:port => :sysdatad)

      @remote_handlers = Config[:sysmoond]['remotes'].map {|ip|
        unless Utils::local_ip?(ip)
          next IPC::Client.new(
                 :port => :syshand,
                 :ip => ip
               )
        end
      }.compact

    end
  end
end
