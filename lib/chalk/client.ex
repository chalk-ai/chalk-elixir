defmodule Chalk.Client do
  @version Chalk.Mixfile.project()[:version]

  @spec new(map) :: Tesla.Client.t()
  def new(config \\ %{}) do
    middleware =
      get_base_middleware(config) ++
        get_authentication_middleware(config) ++ get_middleware(config)

    adapter = {get_adapter(config), get_http_options(config)}

    Tesla.client(middleware, adapter)
  end

  # HELPERS

  defp get_base_url(config) do
    config[:api_server] || "https://api.chalk.ai/"
  end

  defp get_base_middleware(config) do
    deployment_id_header =
      case get_deployment_id(config) do
        id when not is_nil(id) ->
          [{"x-chalk-preview-deployment", id}]

        _ ->
          []
      end

    [
      {Tesla.Middleware.BaseUrl, get_base_url(config)},
      {Tesla.Middleware.Headers,
       [
         {"Content-Type", "application/json"},
         {"user-agent", "chalk-elixir v#{@version}"}
         | deployment_id_header
       ]},
      Tesla.Middleware.JSON
    ]
  end

  defp get_authentication_middleware(config) do
    unauthenticated? = Map.get(config, :unauthenticated, false)

    if unauthenticated? do
      []
    else
      [
        {Chalk.Tesla.CredentialsMiddleware,
         %{
           client_id: get_client_id(config),
           client_secret: get_client_secret(config),
           api_server: get_base_url(config)
         }}
      ]
    end
  end

  defp get_middleware(config) do
    case config[:middleware] || [] do
      middleware when is_list(middleware) ->
        middleware

      m ->
        [m]
    end
  end

  defp get_client_id(config) do
    Map.get(config, :client_id) || Application.get_env(:chalk, :chalk_client_id) ||
      System.get_env("CHALK_CLIENT_ID")
  end

  defp get_client_secret(config) do
    Map.get(config, :client_secret) || Application.get_env(:chalk, :chalk_client_secret) ||
      System.get_env("CHALK_CLIENT_SECRET")
  end

  defp get_deployment_id(config) do
    Map.get(config, :deployment_id) || Application.get_env(:chalk, :deployment_id) ||
      System.get_env("DEPLOYMENT_ID")
  end

  defp get_adapter(config) do
    Map.get(config, :adapter) || Application.get_env(:chalk, :adapter) ||
      Tesla.Adapter.Hackney
  end

  defp get_http_options(config) do
    Keyword.merge(
      Application.get_env(:chalk, :http_options, []),
      config[:http_options] || []
    )
  end

  defmodule Request do
    @moduledoc """
    Data structure for an HTTP request with convenience functions.
    """

    @derive Jason.Encoder
    defstruct body: %{}, endpoint: nil, method: nil, opts: %{}
    @type t :: %__MODULE__{body: map, endpoint: String.t(), method: atom, opts: map}

    @doc """
    Convert `Request` to `options` format passed to `Tesla.request/2`.
    """
    @spec to_options(Request.t()) :: keyword
    def to_options(%Request{body: b, endpoint: e, method: m, opts: o}) do
      [method: m, url: e, body: b, opts: Map.to_list(o)]
    end

    @doc """
    Add telemetry metadata to `Request`.
    Calling without the second argument adds default metadata. Custom metadata
    is added by passing a map with a key `telemetry_metadata`.
    Example
    ```
    Request.add_metadata(request, %{telemetry_metadata: %{k: v}})
    ```
    """
    @spec add_metadata(Request.t()) :: Request.t()
    @spec add_metadata(Request.t(), map) :: Request.t()
    def add_metadata(%Request{endpoint: e, method: m, opts: o} = request, config \\ %{}) do
      metadata =
        Map.new()
        |> Map.put(:method, m)
        |> Map.put(:path, e)
        |> Map.put(:u, :native)
        |> Map.merge(config[:telemetry_metadata] || %{})

      %{request | opts: Map.put(o, :metadata, metadata)}
    end
  end
end
