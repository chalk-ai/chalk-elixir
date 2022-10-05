defmodule Chalk.Client do
  @spec new(map) :: Tesla.Client.t()


  defp get_base_url(config) do
    "https://api.chalk.ai/v1/"
  end

  defp get_metadata(config) do
    %{metadata: %{}}
  end

  defp get_middleware(config) do
    []
  end

  def new(config \\ %{}) do
    middleware =
      [
        {Tesla.Middleware.BaseUrl, get_base_url(config)},
        {Tesla.Middleware.Headers,
         [
           {"Content-Type", "application/json"},
           {"user-agent", "chalk-elixir"},
           # {"CLIENT-ID", get_client_id(config)},
           # {"SECRET", get_secret(config)}
         ]},
        Tesla.Middleware.JSON,
        {Tesla.Middleware.Telemetry, get_metadata(config)}
      ] ++ get_middleware(config)

    adapter = {get_adapter(config), get_http_options(config)}

    Tesla.client(middleware, adapter)
  end


  defp get_adapter(config) do
    config[:adapter] || Application.get_env(:chalk, :adapter) || Tesla.Adapter.Hackney
  end


  defp get_http_options(config) do
    Keyword.merge(
      Application.get_env(:chalk, :http_options, []),
      config[:http_options] || []
    )
  end

end
