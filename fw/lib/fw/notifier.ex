defmodule Fw.Notifier do
  use GenStage
  use Timex

  alias Fw.Perception

  require Logger

  def start_link(delay_in_seconds \\ 300, sender \\ nil) do
    initial = %{
      timestamp: Timex.now(),
      delay: delay_in_seconds || 300,
      sender: sender
    }

    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def init(state) do
    opts = [subscribe_to: [{Fw.Sensor, min_demand: 0, max_demand: 1}]]
    {:consumer, state, opts}
  end

  def wait_during(%{seconds: delay}) do
    GenStage.cast(__MODULE__, {:delay_in_seconds, delay})
  end

  def handle_cast({:delay_in_seconds, delay}, state) do
    Logger.info "Notifier: received custom #{delay} seconds delay"
    {:noreply, [], %{state | timestamp: next_timestamp(delay)}}
  end

  def handle_events(_events, _from, state) do
    Logger.info "Notifier: received demand"
    case Timex.before?(state[:timestamp], Timex.now()) do
      true ->
        if(!Perception.found_authorized_device?(), do: sender(state).notify())
        {:noreply, [], %{state | timestamp: next_timestamp(state[:delay])}}
      _ ->
        {:noreply, [], state}
    end
  end

  defp sender(state) do
    case state[:sender] do
      nil -> Fw.Notifier.Sender
      sender -> sender
    end
  end

  defp next_timestamp(delay) do
    Timex.shift(Timex.now(), seconds: delay)
  end
end
