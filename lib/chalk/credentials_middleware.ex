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
      {:ok, token_response} ->
        headers = [
          {"Authorization", "Bearer #{token_response.access_token}"},
        ]

        # If the client_id and client_secret we're using are pegged to a specific environment,
        # roundtrip this as a hint to the load balancer
        if token_response.primary_environment != nil do
          headers = [headers | {"X-Chalk-Env-Id", token_response.primary_environment}]
        end

        env
        |> Tesla.put_headers(headers)
        |> Tesla.run(next)

      {:error, detail} ->
        IO.inspect(detail)
        Tesla.run(env, next)
    end
  end
end
