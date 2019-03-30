require 'socket'
require 'sysmoon/log'
require 'sysmoon/ipc/client'
require 'sysmoon/utils'

module Sysmoon
  class Sync
    def initialize
      @discovery = Discovery.new
    end

    # = Synopsis
    #
    # Starting Synchronization between nodes that are
    # found. Checking if all events are synchronized and
    # synchronizing missing events.
    #
    # = TODO
    #
    # * Catch the time when an event is sent while synchronizing
    def synchronize
      @discovery.send_discovery_message
      # Check for uncatched events
      # Fetch these events if there are some
    end

    private

    # We only recieve, dont push events to synchronize.
    # This is because some node may be setted not to
    # synchronize, so we don't want to make them synching.
    def get_unrecieved_events
      # get events diff
      # pull only unrecieved
    end

    # Using Longest common subsequence problem solution
    # we find timestamps that are absent in our database.
    #
    # Order doesn't matter because we sort events
    #
    # May be consider using any existing solution
    def get_events_diff
      # Get a list of local events
      # Get a list of remote events
      # Find a diff
      #  Build a table
      #  Compose a longest common subsequence
      #  Find the diff using it
    end
  end

  class Discovery

    DISCOVERY_REQ = 'SYSMOON'
    DISCOVERY_ANS = 'DISCOVERED'

    def initialize
      # Starting thread that sends and accepts UDP-packages.
      # This is how a node can say that it's online
      @port = 77342
      @listen_thread = Thread.new { listen_discovery }
      @sysmoon = IPC::Client.new(
        port: :sysmoond
      )
      @listen_sock = UDPSocket.new
      @listen_sock.bind('0.0.0.0', @port)
    end

    # UDP on broadcast
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
