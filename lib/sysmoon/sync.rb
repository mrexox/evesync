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
      @sysdata = IPC::Client.new(
        port: :sysdatad
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
      Log.debug('Synchronizing... start')
      events = missed_events
      if not events.empty?
        fetch_events events
      end
      Log.debug('Synchronizing... end')
    end

    def discover
      @discovery.send_discovery_message
    end

    private

    # We only recieve, dont push events to synchronize.
    # This is because some node may be setted not to
    # synchronize, so we don't want to make them synching.
    def missed_events
      remote_events = {}
      remote_handlers = @sysmoon.remote_handlers

      unless remote_handlers.respond_to? :each
        return Hash.new
      end

      remote_handlers.each do |handler|
        remote_events[handler.ip] = handler.events || {}
      end

      if remote_events.empty?
        return Hash.new
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
      Log.debug('Remote:', remote)
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
      diff = diff_missed(
        v1: local,
        v2: remote_objects.map { |k,v|
          [k, v.keys]
        }.to_h)


      # Returning duplicate
      #remote_diff = remote_objects.full_dup
      #remote_diff
      diff.map do |obj, tms|
        [
          obj,                  # 1
          tms.map do |t|
            [t, remote_objects[obj][t]]
          end.to_h              # 2
        ]
      end.to_h
    end

    # Diffs missed of `v1' that `v2' contain
    def diff_missed(params)
      v1 = params[:v1]
      v2 = params[:v2]

      Log.debug(v1)
      Log.debug(v2)
      # Fully missed objects
      fully_missed = v2.select { |k| not v1.include?(k) }

      # Included in both, but may be missed in `v1'
      maybe_missed = v2.select { |k| v1.include?(k) }

      not_relevant = maybe_missed.select do |k,v|
        v.max > v1[k].max
      end

      partially_missed = not_relevant.map do |k,v|
        [k, v.select { |tms| tms > v1[k].max }]
      end.to_h

      fully_missed.merge(partially_missed)
    end

    def fetch_events(events_diff)

    end
  end

  class Discovery

    DISCOVERY_REQ = 'SYSMOON'.freeze
    DISCOVERY_ANS = 'DISCOVERED'.freeze

    def initialize
      # Starting thread that sends and accepts UDP-packages.
      # This is how a node can say that it's online
      @sysmoon = IPC::Client.new(
        port: :sysmoond
      )
      @port = Config[:sync]['port']
      @listen_sock = UDPSocket.new
      @listen_sock.bind('0.0.0.0', @port)
      @listen_thread = Thread.new { listen_discovery }
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
          Log.info("Discovery host found: #{node_ip}")
          send_discovery_message(node_ip, DISCOVERY_ANS)
        when DISCOVERY_ANS
          Log.info("Discovery host answered: #{node_ip}")
        end
      end
    end
  end
end
