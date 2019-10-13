require 'evesync/ipc/client'
require 'evesync/log'
require 'evesync/config'
require 'evesync/os'

require 'json'

module Evesync

  ##
  # Discover other nodes
  # Handles discovering messages sending and receiving
  #
  # = Example
  #
  #   disc = Discover.new
  #   disc.send_discovery_message
  #   ...
  #   disc.stop

  class Discover
    DISCOVERY_REQ = 'EVESYNC'.freeze
    DISCOVERY_ANS = 'DISCOVERED'.freeze

    def initialize
      # Starting thread that sends and accepts UDP-packages.
      # This is how a node can say that it's online
      @evesync = IPC::Client.new(
        port: :evemond
      )
      @port = Config[:evesyncd]['broadcast_port']
      @listen_sock = UDPSocket.new
      @listen_sock.bind('0.0.0.0', @port)
      @listen_thread = Thread.new { listen_discovery }
    end

    ##
    # Sending UDP message on broadcast
    # Discovering our nodes

    def send_discovery_message(ip='<broadcast>', message=DISCOVERY_REQ)
      udp_sock = UDPSocket.new
      if is_broadcast(ip)
        udp_sock.setsockopt(
          Socket::SOL_SOCKET, Socket::SO_BROADCAST, true
        )
      end
      udp_sock.send(to_discover_msg(message: message), 0, ip, @port)
      udp_sock.close
    end

    def stop
      @listen_thread.exit
    end

    private

    def listen_discovery
      loop do
        datajson, recvdata = @listen_sock.recvfrom(1024)
        node_ip = recvdata[-1]

        next if Utils.local_ip?(node_ip)

        data = from_discover_msg(datajson)
        if fine_node?(data)
          # Push new node_ip to trigger
          @evesync.add_remote_node(node_ip)
        end

        case data['message']
        when DISCOVERY_REQ
          Log.info("Discover host request got: #{node_ip}")
          send_discovery_message(node_ip, DISCOVERY_ANS)
        when DISCOVERY_ANS
          Log.info("Discover host response got: #{node_ip}")
        end
      end
    end

    def to_discover_msg(msg)
      {
        evesync: {
          message: msg,
          os: EVESYNC_OS,
        }
      }.to_json.freeze
    end

    def from_discover_msg(data)
      JSON.parse(data)['evesync'] # TODO: catch error
    end

    def is_broadcast(ip)
      ip == '<broadcast>'
    end

    def fine_node?(data)
      [
        [DISCOVERY_ANS, DISCOVERY_REQ].include?(data['message']),
        data['os'] == EVESYNC_OS,
      ].all?
    end
  end
end
