defmodule Chalk.Tesla.CredentialsMiddleware do
  alias Chalk.Common.ChalkCredentialsError

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
      {:ok, %{access_token: access_token, primary_environment: primary_environment}} ->
        headers =
          [
            {"Authorization", "Bearer #{access_token}"}
          ] ++
            if primary_environment != nil do
              [{"X-Chalk-Env-Id", primary_environment}]
            else
              []
            end

        env
        |> Tesla.put_headers(headers)
        |> Tesla.run(next)

      {:error, error} ->
        {:current_stacktrace, stacktrace} = Process.info(self(), :current_stacktrace)

        {:error,
         %ChalkCredentialsError{
           error: inspect(error),
           stacktrace: inspect(stacktrace)
         }}
    end
  end
end
