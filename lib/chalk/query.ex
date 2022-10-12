defmodule Chalk.Query do
  alias Chalk.Client
  alias Chalk.Client.Request
  alias Chalk.Common.ChalkError
  alias Chalk.Common.ChalkException

  defmodule FeatureMeta do
    defstruct chosen_resolver_fqn: nil,
              cache_hit: nil

    @type t :: %__MODULE__{
            chosen_resolver_fqn: String.t(),
            cache_hit: boolean()
          }
  end

  defmodule FeatureResult do
    defstruct error: nil,
              field: nil,
              meta: nil,
              ts: nil,
              value: nil

    @type t :: %__MODULE__{
            error: ChalkError.t(),
            field: String.t(),
            meta: FeatureMeta.t(),
            ts: String.t(),
            value: any()
          }
  end

  defmodule QueryMeta do
    defstruct execution_duration_s: nil,
              deployment_id: nil,
              query_id: nil

    @type t :: %__MODULE__{
            execution_duration_s: float(),
            deployment_id: String.t(),
            query_id: String.t()
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
    Poison.Decode.transform(body, %{
      as: %OnlineQueryResponse{
        data: [
          %FeatureResult{
            error: %ChalkError{
              exception: %ChalkException{}
            },
            meta: %FeatureMeta{}
          }
        ],
        errors: [%ChalkError{}],
        meta: [%QueryMeta{}]
      }
    })
  end
end
