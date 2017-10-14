defmodule Fw.Sensor do
  use GenStage

  require Logger

  @gpio_module Application.get_env(:fw, __MODULE__)[:gpio]

  def start_link(_) do
    GenStage.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, input_pid} = @gpio_module.start_link(7, :input)
    @gpio_module.set_int(input_pid, :both)
    {:producer, state}
  end

  def handle_info({:gpio_interrupt, _, :rising}, %{demanding: true}) do
    Logger.info "Sensor: received rising and demanding"
    {:noreply, [:movement], %{}}
  end
  def handle_info({:gpio_interrupt, _, :rising}, _state) do
    Logger.info "Sensor: received message rising"
    {:noreply, [], %{state: :rising}}
  end

  def handle_info({:gpio_interrupt, _, :falling}, state) do
    Logger.info "Sensor: received message falling"
    new_state = Map.put(state, :state, :falling)
    {:noreply, [], new_state}
  end

  def handle_demand(_demand, %{state: :rising}) do
    Logger.info "Sensor: handle demand and rising"
    {:noreply, [:movement], %{}}
  end
  def handle_demand(_demand, _state) do
    Logger.info "Sensor: handle demand"
    {:noreply, [], %{demanding: true}}
  end
end
