defmodule Fw.Sensor.FakeGPIO do
  use GenServer

  def start_link(_pin, _type) do
    GenServer.start_link(__MODULE__, %{})
  end

  def set_int(pid, direction) do
    GenServer.call(pid, {:set_int, direction, self()})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info(:falling, state) do
    Process.send(state[:requestor], {:gpio_interrupt, 7, :falling}, [])
    schedule(:rising)
    {:noreply, state}
  end
  def handle_info(:rising, state) do
    Process.send(state[:requestor], {:gpio_interrupt, 7, :rising}, [])
    schedule(:falling)
    {:noreply, state}
  end

  def handle_call({:set_int, _direction, requestor}, _from, _state) do
    schedule(:rising)
    {:reply, {:ok},  %{requestor: requestor }}
  end

  defp schedule(type) do
    Process.send_after(self(), type, 1000 * 20)
  end
end
