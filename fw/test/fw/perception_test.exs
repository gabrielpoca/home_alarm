defmodule Fw.PerceptionTest do
  use ExUnit.Case

  @allowed_addresses Application.get_env(:fw, Fw.Perception)[:allowed_mac_addresses]

  defmodule TestArpScan do
    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, %{addresses: []}, name: __MODULE__)
    end

    def init(state) do
      {:ok, state}
    end

    def get_mac_addresses do
      GenServer.call(__MODULE__, {:get})
    end

    def set_mac_addresses(addresses) do
      GenServer.call(__MODULE__, {:set, addresses})
    end

    def handle_call({:get}, _from, state) do
      {:reply, state[:addresses], state}
    end

    def handle_call({:set, addresses}, _from, _state) do
      {:reply, :ok, %{addresses: addresses}}
    end
  end

  test "finds authorized devices on the network" do
    {:ok, _pid} = TestArpScan.start_link()
    {:ok, perception_pid} = Fw.Perception.start_link(TestArpScan)

    assert Fw.Perception.found_authorized_device?() == false

    TestArpScan.set_mac_addresses(@allowed_addresses)
    Process.send(perception_pid, :run, [])

    assert Fw.Perception.found_authorized_device?() == true

    TestArpScan.set_mac_addresses([])
    Process.send(perception_pid, :run, [])

    assert Fw.Perception.found_authorized_device?() == false
  end
end
