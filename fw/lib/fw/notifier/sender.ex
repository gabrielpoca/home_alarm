defmodule Fw.Notifier.Sender do
  use Retry

  require Logger

  @url Application.get_env(:fw, Fw.Notifier)[:url]

  def notify do
    retry with: exp_backoff(10_000) |> expiry(86_400_000), rescue_only: [MatchError]  do
      opts = [
        headers: [
          "Content-Type": "application/x-www-form-urlencoded"
        ]
      ]

      Logger.info "Sender: sending notification"
      %HTTPotion.Response{status_code: 200} = HTTPotion.post @url, opts
    end

    Logger.info "Sender: notification sent"
  end
end
