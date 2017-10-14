defmodule Fw.Sensor.TestGPIO do
  use GenServer

  def start_link(_pin, _type) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def set_int(_pid, direction) do
    GenServer.call(__MODULE__, {:set_int, direction, self()})
  end

  def send_rising do
    GenServer.call(__MODULE__, :rising)
  end

  def send_falling do
    GenServer.call(__MODULE__, :falling)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:falling, _from, state) do
    Process.send(state[:requestor], {:gpio_interrupt, 7, :falling}, [])
    {:reply, [], state}
  end
  def handle_call(:rising, _from, state) do
    Process.send(state[:requestor], {:gpio_interrupt, 7, :rising}, [])
    {:reply, [], state}
  end

  def handle_call({:set_int, _direction, requestor}, _from, _state) do
    {:reply, {:ok},  %{requestor: requestor }}
  end
end
