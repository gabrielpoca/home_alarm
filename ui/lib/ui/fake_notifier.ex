defmodule Ui.FakeNotifier do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def wait_during(%{seconds: delay}) do
    GenServer.call(__MODULE__, {:delay_in_seconds, delay})
  end

  def handle_call({:delay_in_seconds, delay}, _from, state) do
    Logger.info "Notifier: received #{delay} seconds delay"
    {:reply, :ok, state}
  end
end
