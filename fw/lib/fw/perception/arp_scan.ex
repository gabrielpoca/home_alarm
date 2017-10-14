defmodule Fw.Perception.ArpScan do
  def get_mac_addresses() do
    System.cmd("arp-scan", ["--localnet", "--interface=wlan0"])
    |> elem(0)
    |> String.split("\n")
    |> Enum.filter(fn(s) -> Regex.match?(~r/192/, s) end)
    |> Enum.map(&(String.split(&1, "\t")))
    |> Enum.map(&Enum.at(&1, 1))
  end
end
