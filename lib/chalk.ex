defmodule Chalk do
  @moduledoc """
  An HTTP Client for the Chalk Feature Engine

  [Chalk Documentation](https://docs.chalk.ai/docs/what-is-chalk)
  """

  @type mapper :: (any() -> any())


  @callback send_request(Request.t(), Tesla.Client.t()) :: {:ok, Tesla.Env.t()} | {:error, any()}
end
