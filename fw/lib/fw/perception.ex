defmodule Fw.Perception do
  use GenServer

  require Logger

  @arp_scan Application.get_env(:fw, Fw.Perception)[:arp_scan]
  @allowed_addresses Application.get_env(:fw, Fw.Perception)[:allowed_mac_addresses]

  def start_link(arp_scan \\ nil) do
    initial = %{
      arp_scan: arp_scan,
      found_authorized_device: false
    }

    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def init(state) do
    schedule_run(0)
    {:ok, state}
  end

  def found_authorized_device? do
    GenServer.call(__MODULE__, :found_authorized_device)
  end

  def handle_call(:found_authorized_device, _from, state) do
    {:reply, state[:found_authorized_device], state}
  end

  def handle_info(:run, state) do
    schedule_run()
    new_state = Map.merge(state, %{found_authorized_device: any_authorized_device?(state)})
    {:noreply, new_state}
  end

  defp schedule_run(seconds \\ 30_000) do
    Process.send_after(self(), :run, seconds)
  end

  defp any_authorized_device?(state) do
    wifi_mac_addresses(state)
    |> Enum.any?(&Enum.member?(@allowed_addresses, &1))
  end

  defp wifi_mac_addresses(state) do
    arp_scan(state).get_mac_addresses()
  end

  defp arp_scan(state) do
    case state do
      %{arp_scan: nil} -> @arp_scan
      %{arp_scan: arp_scan} -> arp_scan
    end
  end
end
