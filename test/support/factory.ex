defmodule Chalk.Factory do
  @moduledoc false


  def http_response_body(:error) do
    %{http_code: 200}
  end

end
