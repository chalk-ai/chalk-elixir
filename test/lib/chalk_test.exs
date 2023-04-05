defmodule ChalkTest do
  use ExUnit.Case, async: true

  alias Chalk.Client
  alias Chalk.Client.Request

  @moduletag :Chalk

  defmodule Result, do: defstruct([:some])

  describe "Client" do
    test "has correct user agent" do
      %Tesla.Client{pre: pre} = Client.new()

      {"user-agent", user_agent} =
        pre
        |> Enum.find(fn
          {Tesla.Middleware.Headers, :call, _} -> true
          _ -> false
        end)
        |> then(fn {_, _, [headers]} -> headers end)
        |> Enum.find(fn
          {"user-agent", _} -> true
          _ -> false
        end)

      assert user_agent =~ Chalk.Mixfile.project()[:version]
    end
  end

  describe "Chalk send_request/2" do
    setup do
      bypass = Bypass.open()
      Application.put_env(:Chalk, :root_uri, "http://localhost:#{bypass.port}/")

      config = %{
        client_id: "my-client",
        secret: "my-secret"
      }

      client = Client.new(config)
      request = %Request{method: :post, endpoint: "some/endpoint", body: %{some: "body"}}

      {:ok, bypass: bypass, client: client, request: request}
    end
  end

  describe "Chalk ExchangeCredentials" do
    test "exchanges a valid client id and secret for an access token" do
      assert 1 ==
               Chalk.Client.ExchangeCredentials.exchange_credentials(%{
                 client_id: System.get_env("CHALK_CLIENT_ID"),
                 client_secret: System.get_env("CHALK_CLIENT_SECRET"),
                 grant_type: "client_credentials"
               })
    end
  end

  describe "Chalk Query" do
    test "can roundtrip a query for an input feature" do
      assert 1 ==
               Chalk.Query.online(%{
                 inputs: %{
                   "user.id": 1
                 },
                 outputs: [
                   "user.id"
                 ]
               })
    end

    test "can roundtrip a query for an additional feature" do
      assert 1 ==
               Chalk.Query.online(%{
                 inputs: %{
                   "user.id": 1
                 },
                 outputs: [
                   "user.id",
                   "user.full_name"
                 ]
               })
    end

    test "can pass credentials as an argument" do
      assert 1 ==
        Chalk.Query.online(%{
          inputs: %{
            "user.id": 1
          },
          outputs: [
            "user.id",
            "user.full_name"
          ]
        }, %{
            client_id: "my-client",
            secret: "my-secret"
        })
    end
  end

  def echo_event(event, measurements, metadata, config) do
    send(config.caller, {:event, event, measurements, metadata})
  end
end
