require 'socket'
require 'full_dup'
require 'sysmoon/log'
require 'sysmoon/config'
require 'sysmoon/ipc/client'
require 'sysmoon/utils'

module Sysmoon
  class Sync
    def initialize
      @discovery = Discovery.new
      @sysmoon = IPC::Client.new(
        port: :sysmoond
      )
      @local_sysdata = IPC::Client.new(
        port: :sysdatad
      )
    end

    # = Synopsis
    #
    # Starting Synchronization between nodes that are
    # found. Checking if all events are synchronized and
    # synchronizing missing events.
    #
    # = TODO
    #
    # * Catch the time when an event is sent while
    #   synchronizing
    #
    def synchronize
      @discovery.send_discovery_message
      events = missed_events
      if not events.empty?
        fetch_events events
      end
    end

    private

    # We only recieve, dont push events to synchronize.
    # This is because some node may be setted not to
    # synchronize, so we don't want to make them synching.
    def missed_events
      remote_events = {}
      @sysmoon.remote_handlers.each do |handler|
        events[handler.ip] = handler.db.events
      end
      local_events = @sysdata.events

      events_diff(
        local: local_events,
        remote: remote_events
      )
    end

    # Using Longest common subsequence problem solution
    # we find timestamps that are absent in our database.
    #
    # Order doesn't matter because we sort events
    #
    # May be consider using any existing solution
    def events_diff(params)
      # params:
      #   local = {object [...events]}
      #   remote = {ip => {object => [...events]}
      # convert to
      #   remote = {object => {event => [..ips]}}
      # then
      #   use remote part {object => [...events]} and
      #   compare to local, then get object-event that are
      #   going to be fetched and apply ips (the choice may be random)
      #   that can be used to fetch these events
      local = params[:local]
      remote = params[:remote]

      # Transforming data
      remote_objects = {}
      remote.each do |ip, objects|
        objects.each do |object, events|
          remote_objects[object] ||= {}
          events.each do |event|
            remote_objects[object][event] ||= []
            remote_objects[object][event].push(ip)
          end
        end
      end

      # Applying algorithm
      # ...

      remote_diff = remote_objects.full_dup
      remote_diff
    end
  end

  class Discovery

    DISCOVERY_REQ = 'SYSMOON'
    DISCOVERY_ANS = 'DISCOVERED'

    def initialize
      # Starting thread that sends and accepts UDP-packages.
      # This is how a node can say that it's online
      @port = Config[:sync]['port']
      @listen_thread = Thread.new { listen_discovery }
      @sysmoon = IPC::Client.new(
        port: :sysmoond
      )
      @listen_sock = UDPSocket.new
      @listen_sock.bind('0.0.0.0', @port)
    end

    # Sending UDP message on broadcast
    # Discovering our nodes
    def send_discovery_message(ip='<broadcast>', message=DISCOVERY_REQ)
      udp_sock = UDPSocket.new
      if ip == '<broadcast>'
        udp_sock.setsockopt(
          Socket::SOL_SOCKET, Socket::SO_BROADCAST, true
        )
      end
      udp_sock.send(message, 0, ip, @port)
      udp_sock.close
    end

    private

    def listen_discovery
      loop do
        data, recvdata = @listen_sock.recvfrom(1024)
        node_ip = recvdata[-1]

        next if Utils::local_ip?(node_ip)

        if [DISCOVERY_REQ, DISCOVERY_ANS].include? data
          # Push new node_ip to trigger
          @sysmoon.add_remote_node(node_ip)
        end

        case data
        when DISCOVERY_REQ
          Log.info("Host found: #{node_ip}")
          send_discovery_message(node_ip, DISCOVERY_ANS)
        when DISCOVERY_ANS
          Log.info("Host answered: #{node_ip}")
        end
      end
    end
  end
end
