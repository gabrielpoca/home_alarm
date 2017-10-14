defmodule UiWeb.SleepController do
  use UiWeb, :controller

  @notifier Application.get_env(:ui, :notifier)

  def create(conn, %{"sleep" => %{"hours" => hours}}) do
    {num, _} = Integer.parse(hours)
    @notifier.wait_during(%{seconds: num * 3600})
    redirect conn, to: "/"
  end
end
