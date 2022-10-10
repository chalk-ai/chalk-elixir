defmodule Chalk.Query do
  alias Chalk.Client
  alias Chalk.Client.Request

  defmodule FeatureValue do
    defstruct x: nil

    @type t :: %__MODULE__{
            x: String.t()
          }
  end


  defmodule OnlineQueryResponse do
    @derive Jason.Encoder
    defstruct data: [],
              errors: [],
              meta: nil

    @type t :: %__MODULE__{
            data: [FeatureResult.t()],
            errors: [ChalkError.t()],
            meta: QueryMeta.t()
          }
  end

  @doc """
  Execute an online query
  Parameters
  ```
  %{input: }
  ```
  """
  def online(params, config \\ %{}) do
    request_operation("v1/query/online", params, config)
  end

  defp request_operation(endpoint, params, config) do
    c = config[:client] || Chalk

    Request
    |> struct(method: :post, endpoint: endpoint, body: params)
    |> Request.add_metadata(config)
    |> c.send_request(Client.new(config))
    |> c.handle_response(&map_query_response(&1))
  end

  defp map_query_response(body) do
    Poison.Decode.transform(body, %{as: %OnlineQueryResponse{}})
  end
end
