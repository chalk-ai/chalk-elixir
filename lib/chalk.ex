defmodule Chalk do
  @moduledoc """
  An HTTP Client for the Chalk Feature Engine

  [Chalk Documentation](https://docs.chalk.ai/docs/what-is-chalk)
  """

  alias Chalk.Client.Request

  @type mapper :: (any() -> any())

  @callback send_request(Request.t(), Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, any()}

  @callback handle_response({:ok, Tesla.Env.t()} | {:error, any()}, mapper) ::
              {:ok, term} | {:error, Chalk.Error.t()} | {:error, any()}

  @doc false
  def send_request(request, client) do
    request
    |> Request.to_options()
    |> then(&Tesla.request(client, &1))
  end

  @doc false
  def handle_response({:ok, %Tesla.Env{status: status} = env}, mapper) when status in 200..299 do
    {:ok, mapper.(env.body)}
  end

  def handle_response({:ok, %Tesla.Env{} = env}, _mapper) do
    {:error, env.body}
  end

  def handle_response({:error, _reason} = error, _mapper) do
    error
  end
end
