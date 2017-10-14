defmodule Fw.NotifierTest do
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

  defmodule FakeSender do
    use GenServer

    def start_link(parent) do
      GenServer.start_link(__MODULE__, %{parent: parent}, name: __MODULE__)
    end

    def init(state) do
      {:ok, state}
    end

    def notify do
      GenServer.call(__MODULE__, :notify)
    end

    def handle_call(:notify, _from, state) do
      Process.send(state[:parent], :notify, [])
      {:reply, :ok, state}
    end
  end

  test "sends a notification" do
    {:ok, _arp_scan_pid} = TestArpScan.start_link()
    {:ok, _sender_pid} = FakeSender.start_link(self())
    {:ok, _sensor_pid} = Fw.Sensor.start_link([])
    {:ok, perception_pid} = Fw.Perception.start_link(TestArpScan)
    {:ok, _notifier_pid} = Fw.Notifier.start_link(0, FakeSender)

    TestArpScan.set_mac_addresses @allowed_addresses
    Process.send(perception_pid, :run, [])

    Process.sleep 1000
    Fw.Sensor.TestGPIO.send_rising()

    assert_receive :notify
  end

  test "waits for device to send a notification" do
    {:ok, _arp_scan_pid} = TestArpScan.start_link()
    {:ok, _sender_pid} = FakeSender.start_link(self())
    {:ok, _sensor_pid} = Fw.Sensor.start_link([])
    {:ok, perception_pid} = Fw.Perception.start_link(TestArpScan)
    {:ok, _notifier_pid} = Fw.Notifier.start_link(0, FakeSender)

    Process.sleep 1000
    Fw.Sensor.TestGPIO.send_rising()

    refute_receive :notify

    TestArpScan.set_mac_addresses @allowed_addresses
    Process.send(perception_pid, :run, [])
    Process.sleep 1000
    Fw.Sensor.TestGPIO.send_rising()

    assert_receive :notify
  end

  test "waits before sending a second notification" do
    {:ok, _arp_scan_pid} = TestArpScan.start_link()
    {:ok, _sender_pid} = FakeSender.start_link(self())
    {:ok, _sensor_pid} = Fw.Sensor.start_link([])
    {:ok, perception_pid} = Fw.Perception.start_link(TestArpScan)
    {:ok, _notifier_pid} = Fw.Notifier.start_link(2, FakeSender)

    TestArpScan.set_mac_addresses @allowed_addresses
    Process.send(perception_pid, :run, [])
    Process.sleep 2000
    Fw.Sensor.TestGPIO.send_rising()

    assert_receive :notify

    Process.sleep 1000
    Fw.Sensor.TestGPIO.send_rising()

    refute_receive :notify

    Process.sleep 1000
    Fw.Sensor.TestGPIO.send_rising()

    assert_receive :notify
  end

  test "it waits for a defined amount of time" do
    {:ok, _arp_scan_pid} = TestArpScan.start_link()
    {:ok, _sender_pid} = FakeSender.start_link(self())
    {:ok, _sensor_pid} = Fw.Sensor.start_link([])
    {:ok, perception_pid} = Fw.Perception.start_link(TestArpScan)
    {:ok, _notifier_pid} = Fw.Notifier.start_link(2, FakeSender)

    TestArpScan.set_mac_addresses @allowed_addresses
    Process.send(perception_pid, :run, [])
    Process.sleep 2000
    Fw.Sensor.TestGPIO.send_rising()

    assert_receive :notify

    Fw.Notifier.wait_during(%{seconds: 4})
    Process.sleep 3000
    Fw.Sensor.TestGPIO.send_rising()

    refute_receive :notify

    Process.sleep 1000
    Fw.Sensor.TestGPIO.send_rising()

    assert_receive :notify
  end
end
