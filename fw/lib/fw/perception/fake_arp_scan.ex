defmodule Fw.Perception.FakeArpScan do
  require Logger

  def get_mac_addresses() do
    Logger.debug "Using fake arp-scan"

    ["88:88:88:88:88:88"]
  end
end
