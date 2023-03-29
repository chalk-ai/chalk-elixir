defmodule Chalk.Query do
  alias Chalk.Client
  alias Chalk.Client.Request
  alias Chalk.Common.ChalkError
  alias Chalk.Common.ChalkException

  defmodule FeatureMeta do
    @derive Jason.Encoder
    defstruct cache_hit: nil,
              chosen_resolver_fqn: nil,
              primitive_type: nil,
              version: nil

    @type t :: %__MODULE__{
            cache_hit: boolean(),
            chosen_resolver_fqn: String.t(),
            primitive_type: String.t(),
            version: integer()
          }
  end

  defmodule FeatureResult do
    @derive Jason.Encoder
    defstruct error: nil,
              field: nil,
              meta: nil,
              pkey: nil,
              ts: nil,
              value: nil

    @type t :: %__MODULE__{
            error: ChalkError.t(),
            field: String.t(),
            meta: FeatureMeta.t(),
            pkey: String.t(),
            ts: String.t(),
            value: any()
          }
  end

  defmodule QueryMeta do
    @derive Jason.Encoder
    defstruct deployment_id: nil,
              environment_id: nil,
              environment_name: nil,
              execution_duration_s: nil,
              query_hash: nil,
              query_id: nil,
              query_timestamp: nil

    @type t :: %__MODULE__{
            deployment_id: String.t(),
            environment_id: String.t(),
            environment_name: String.t(),
            execution_duration_s: float(),
            query_hash: String.t(),
            query_id: String.t(),
            query_timestamp: String.t()
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
  """
  @spec online(
          %{
            required(:inputs) => %{
              String.t() => String.t()
            },
            required(:outputs) => [String.t()],
            optional(:staleness) => %{
              String.t() => String.t()
            },
            optional(:context) => %{
              optional(:environment) => String.t(),
              optional(:tags) => [String.t()]
            },
            optional(:deployment_id) => String.t(),
            optional(:query_name) => String.t()
          },
          map()
        ) :: {:ok, OnlineQueryResponse.t()} | {:error, any()}
  def online(params, config \\ %{}) do
    request_operation("v1/query/online", params, config)
  end

  defp request_operation(endpoint, params, config) do
    c = config[:client] || Chalk

    params =
      if deployment_id = Map.get(config, :deployment_id, System.get_env("DEPLOYMENT_ID")) do
        # prefer the deployment_id in params, if it exists
        Map.put_new(params, :deployment_id, deployment_id)
      else
        params
      end

    Request
    |> struct(method: :post, endpoint: endpoint, body: params)
    |> Request.add_metadata(config)
    |> c.send_request(Client.new(config))
    |> c.handle_response(&map_query_response(&1))
  end

  defp map_query_response(body) do
    Poison.Decode.decode(body, %{
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
        meta: %QueryMeta{}
      }
    })
  end
end
