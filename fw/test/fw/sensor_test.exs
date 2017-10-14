defmodule Fw.SensorTest do
  use ExUnit.Case

  setup do
    {:ok, sensor_pid} = Fw.Sensor.start_link([])
    {:ok, sensor: sensor_pid}
  end

  defmodule TestConsumer do
    use GenStage

    def start_link(parent) do
      GenStage.start_link(TestConsumer, %{parent: parent})
    end

    def init(state) do
      {:consumer, state}
    end

    def handle_events(events, _from, state) do
      Process.send(state[:parent], events, [])
      {:noreply, [], state}
    end
  end

  test "it detects movement when rising", %{sensor: sensor} do
    {:ok, consumer_pid} = TestConsumer.start_link(self())
    GenStage.sync_subscribe(consumer_pid, to: sensor)

    Fw.Sensor.TestGPIO.send_rising()

    assert_receive [:movement]
  end
end
