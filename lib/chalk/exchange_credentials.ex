defmodule Chalk.Client.ExchangeCredentials do
  alias Chalk.Client
  alias Chalk.Client.Request

  defmodule Req do
    @derive Jason.Encoder
    defstruct client_id: nil, client_secret: nil, grant_type: nil

    @type t :: %__MODULE__{
            client_id: String.t(),
            client_secret: String.t(),
            grant_type: String.t()
          }
  end

  defmodule Token do
    @derive Jason.Encoder
    # @enforce_keys [:access_token, :expires_in, :expires_at]
    defstruct access_token: nil,
              token_type: nil,
              expires_in: nil,
              expires_at: nil,
              api_server: nil,
              engines: [{nil, nil}]

    @type t :: %__MODULE__{
            access_token: String.t(),
            token_type: String.t(),
            expires_in: integer(),
            expires_at: integer(),
            api_server: String.t(),
            engines: [{String.t(), String.t()}]
          }

    def valid?(%__MODULE__{} = token) do
      {:ok, exp, _} = DateTime.from_iso8601(token.expires_at)
      exp >= DateTime.utc_now() |> DateTime.add(5, :minute)
    end
  end

  def exchange_credentials(params, config \\ %{}) do
    config = config |> Map.put(:unauthenticated, true)
    c = config[:client] || Chalk

    Request
    |> struct(method: :post, endpoint: "v1/oauth/token", body: params)
    |> Request.add_metadata(config)
    |> c.send_request(Client.new(config))
    |> c.handle_response(&map_exchange_credentials(&1))
  end

  defp map_exchange_credentials(body) do
    Poison.Decode.transform(body, %{as: %Token{}})
  end
end
