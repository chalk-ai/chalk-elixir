defmodule ChalkTest do
  use ExUnit.Case, async: true

  alias Chalk.Client
  alias Chalk.Client.Request

  @moduletag :Chalk

  defmodule Result, do: defstruct([:some])

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

    # @describetag :integration
    # test "returns correct values", %{bypass: bypass, client: client, request: request} do
    #   # successful request
    #   Bypass.expect(bypass, fn conn ->
    #     conn
    #     |> Plug.Conn.put_resp_header("content-type", "application/json")
    #     |> Plug.Conn.resp(200, "{\"status\":\"ok\"}")
    #   end)

    #   assert {:ok, %Tesla.Env{status: 200} = env} = Chalk.send_request(request, client)
    #   assert is_map(env.body)

    #   # failed request
    #   Bypass.down(bypass)

    #   assert {:error, :econnrefused} = Chalk.send_request(request, client)
    # end
  end

  describe "Chalk handle_response/2" do
    @describetag :unit

    # test "returns {:ok, term()} and applies mapper fun for http response 200-299" do
    #   env = %Tesla.Env{
    #     status: 200,
    #     body: %{some: "body"}
    #   }

    #   mapper = fn body -> struct(Result, Map.to_list(body)) end

    #   assert {:ok, %Result{some: "body"}} == Chalk.handle_response({:ok, env}, mapper)
    # end

    # test "returns {:error, Chalk.Error.t} for response >=300" do
    #   env = %Tesla.Env{
    #     status: 400,
    #     body: Chalk.Factory.http_response_body(:error)
    #   }

    #   mapper = fn body -> body end

    #   assert {:error, error} = Chalk.handle_response({:ok, env}, mapper)
    #   assert Chalk.Error == error.__struct__
    #   assert error.http_code == env.status
    # end

    # test "returns http failure" do
    #   mapper = fn body -> body end

    #   assert {:error, :econnrefused} = Chalk.handle_response({:error, :econnrefused}, mapper)
    # end
  end

  describe "Chalk ExchangeCredentials" do
    test "exchanges a valid client id and secret for an access token" do
      assert 1 ==
               Chalk.Client.ExchangeCredentials.exchange_credentials(
                 %{
                   client_id: System.get_env("CHALK_CLIENT_ID"),
                   client_secret: System.get_env("CHALK_CLIENT_SECRET"),
                   grant_type: "client_credentials"
                 },
                 %{api_server: "http://localhost:8000"}
               )
    end
  end

  describe "Chalk Query" do
    test "can roundtrip a query for an input feature" do
      assert 1 ==
               Chalk.Query.online(
                 %{
                   inputs: %{
                     "user.id": "user_id"
                   },
                   outputs: [
                     "user.id"
                   ]
                 },
                 %{api_server: "http://localhost:8000"}
               )
    end

    test "can roundtrip a query for an additional feature" do
      assert 1 ==
               Chalk.Query.online(
                 %{
                   inputs: %{
                     "user.id": "u_f4uN7hF7L5"
                   },
                   outputs: [
                     "user.id",
                     "user.full_name"
                   ]
                 },
                 %{api_server: "http://localhost:8000"}
               )
    end
  end

  def echo_event(event, measurements, metadata, config) do
    send(config.caller, {:event, event, measurements, metadata})
  end
end
