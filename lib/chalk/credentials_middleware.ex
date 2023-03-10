defmodule Chalk.Tesla.CredentialsMiddleware do
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, options) do
    # Tesla.run(env, next)
    params = %{
      client_id: options[:client_id],
      client_secret: options[:client_secret],
      grant_type: "client_credentials"
    }

    result =
      Chalk.Client.ExchangeCredentials.exchange_credentials(params, %{
        api_server: options[:api_server]
      })

    case result do
      {:ok, token} ->
        env
        |> Tesla.put_headers([{"Authorization", "Bearer #{token.access_token}"}])
        |> Tesla.run(next)

      {:error, detail} ->
        Tesla.run(env, next)
    end
  end
end
