defmodule Chalk.Client.CredentialsCache do
  @moduledoc false

  use GenServer

  alias Chalk.Client.ExchangeCredentials.Token

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get() do
    GenServer.call(__MODULE__, {:get, %{}})
  end

  def get(config) do
    GenServer.call(__MODULE__, {:get, config})
  end

  @impl true
  def init(:ok) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:get, config}, _from, nil) do
    get_access_token(config)
  end

  def handle_call({:get, config}, _from, %Token{} = token) do
    if Token.valid?(token) do
      {:reply, token, token}
    else
      get_access_token(config)
    end
  end

  defp get_access_token(config) do
    params = %{
      client_id: "",
      client_secret: ""
    }

    res = Chalk.Client.ExchangeCredentials.exchange_credentials(params, config)

    case res do
      :error ->
        {:reply, :error, nil}

      access_token ->
        {:reply, access_token, access_token}
    end
  end
end
