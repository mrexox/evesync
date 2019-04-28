require 'socket'
require 'full_dup'
require 'evesync/discover'
require 'evesync/log'
require 'evesync/config'
require 'evesync/ipc/client'
require 'evesync/ipc/data/utils'
require 'evesync/utils'

module Evesync
  class Sync
    def initialize
      @discovery = Discover.new
      @monitor = IPC::Client.new(
        port: :evemond
      )
      @database = IPC::Client.new(
        port: :evedatad
      )
      @handler = IPC::Client.new(
        port: :evehand
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
      Log.debug('Synchronizing starting...')
      apply_events fetch_events missed_events
      Log.debug('Synchronizing done!')
    end

    def discover
      @discovery.send_discovery_message
    end

    def apply_events(events)
      events.each do |_, message|
        message.values.each do |json|
          ipc_message = IPC::Data.from_json(json)
          @handler.handle(ipc_message)
        end
      end
    end

    # Diffs missed of `v1' that `v2' contain
    def self.diff_missed(params)
      v1 = params[:v1]
      v2 = params[:v2]

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

    private

    # We only recieve, dont push events to synchronize.
    # This is because some node may be setted not to
    # synchronize, so we don't want to make them synching.
    def missed_events
      remote_events = {}
      remote_handlers = @monitor.remote_handlers

      return {} unless remote_handlers.respond_to? :each

      remote_handlers.each do |handler|
        begin
          Log.debug('Synchronizing with host (IP):', handler.ip)
          remote_events[handler.ip] = handler.events || {}
        rescue
          next
        end
      end

      return {} if remote_events.empty?

      local_events = @database.events

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
      Log.debug('Synchronizing remote objects:', remote)
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

    # Fetch events from given diff.
    #   events_diff: {object => {event => [ip..]}}
    def fetch_events(events_diff)
      if events_diff.empty?
        Log.info('Synchronizing no events')
        return {}
      end

      # Getting {ip => handler} map
      handlers = {}
      @monitor.remote_handlers.each do |handler|
        handlers[handler.ip] = handler
      end

      # Mapping events to nodes: {ip => {object => [events...]}}
      nodes_events = map_nodes_for_events(events_diff, handlers)

      # Fetching
      messages = {}
      nodes_events.each do |ip, events|
        messages.merge! handlers[ip].messages(events)
      end
      Log.debug('Synchronizing events fetched:', messages)
      messages
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
