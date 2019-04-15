require 'socket'
require 'full_dup'
require 'sysmoon/discover'
require 'sysmoon/log'
require 'sysmoon/config'
require 'sysmoon/ipc/client'
require 'sysmoon/ipc/data/hashable'
require 'sysmoon/utils'

module Sysmoon
  class Sync
    def initialize
      @discovery = Discover.new
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
      fetch_events events unless events.empty?
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

      return {} unless remote_handlers.respond_to? :each

      remote_handlers.each do |handler|
        begin
          Log.debug('Remote ip to sync:', handler.ip)
          remote_events[handler.ip] = handler.events || {}
        rescue
          next
        end
      end

      return {} if remote_events.empty?

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
        v2: remote_objects.map do |k, v|
          [k, v.keys]
        end.to_h
      )

      # Returning duplicate
      # remote_diff = remote_objects.full_dup
      # remote_diff
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

      Log.debug('Local  events', v1)
      Log.debug('Remote events', v2)
      # Fully missed objects
      fully_missed = v2.reject { |k| v1.include?(k) }

      # Included in both, but may be missed in `v1'
      maybe_missed = v2.select { |k| v1.include?(k) }

      not_relevant = maybe_missed.select do |k, v|
        v.max > v1[k].max
      end

      partially_missed = not_relevant.map do |k, v|
        [k, v.select { |tms| tms > v1[k].max }]
      end.to_h

      fully_missed.merge(partially_missed)
    end

    # Fetch events from given diff.
    #   events_diff: {object => {event => [ip..]}}
    def fetch_events(events_diff)
      # Getting {ip => handler} map
      handlers = {}
      @sysmoon.remote_handlers.each do |handler|
        handlers[handler.ip] = handler
      end

      # Mapping events to nodes: {ip => {object => [events...]}}
      nodes_events = map_nodes_for_events(evnts_diff, handlers)

      # Fetch...

      # Apply...

      Log.debug('Events to fetch:', events_to_fetch)
      # TODO: fetch events
      # parse them into objects
      # local @syshand -> handle(message)
    end

    # Map events to appropriate nodes that can be used to
    # fetch events.
    # TODO: intellectual choosing the nodes to fetch msgs from.
    # Now choosing the firs matched one for most of the events.
    def map_nodes_for_events(events_diff, handlers)
      nodes_events = {}
      events_diff.each do |object, events|
        events.each do |event, nodes|
          handlers.keys.each do |ip|
            if nodes.include?(ip)
              nodes_events[ip] ||= {}
              nodes_events[ip][object] ||= []
              nodes_events[ip][object].push(event)
              break
            end
          end
        end
      end
      nodes_events
    end
  end
end
