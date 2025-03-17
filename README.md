# Chalk Elixir

[![Dialyxir](https://github.com/chalk-ai/chalk-elixir/actions/workflows/dialyxir.yaml/badge.svg)](https://github.com/chalk-ai/chalk-elixir/actions/workflows/dialyxir.yaml)
[![Integration tests](https://github.com/chalk-ai/chalk-elixir/actions/workflows/integration-test.yaml/badge.svg)](https://github.com/chalk-ai/chalk-elixir/actions/workflows/integration-test.yaml)
[![Publish to Hex](https://github.com/chalk-ai/chalk-elixir/actions/workflows/publish.yaml/badge.svg)](https://github.com/chalk-ai/chalk-elixir/actions/workflows/publish.yaml)

[![Hex.pm](https://img.shields.io/hexpm/v/chalk_elixir.svg)](https://hex.pm/packages/chalk_elixir)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/chalk_elixir/)
[![Hex.pm](https://img.shields.io/hexpm/dt/chalk_elixir.svg)](https://hex.pm/packages/chalk_elixir)
[![Hex.pm](https://img.shields.io/hexpm/dw/chalk_elixir.svg)](https://hex.pm/packages/chalk_elixir)

<p align="center">
  <img src="assets/chalk-logo.png" alt="Chalk Logo" width="150" />
</p>

Official Elixir client for [Chalk](https://chalk.ai) Online Queries. This library provides an easy way to integrate with Chalk's API for feature computation and serving.

## Installation

Add `chalk_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chalk_elixir, "~> 0.0.12"}
  ]
end
```

## Usage

### Basic Query

Online queries are executed by calling `Chalk.Query.online/2` and passing inputs and expected outputs as described in the [Chalk API documentation](https://docs.chalk.ai/docs/query-basics).

```elixir
{:ok, response} = Chalk.Query.online(%{
  inputs: %{
    "user.id": 1
  },
  outputs: [
    "user.id",
    "user.email",
    "user.credit_score"
  ]
})
```

### Advanced Options

The query can include additional options:

```elixir
{:ok, response} = Chalk.Query.online(%{
  inputs: %{
    "user.id": 1
  },
  outputs: [
    "user.id",
    "user.email",
    "user.credit_score"
  ],
  staleness: %{
    "user.credit_score": "1d" # Allow data up to 1 day old
  },
  context: %{
    environment: "production",
    tags: ["high-priority"]
  },
  query_name: "user_profile_query" # For telemetry and observability
})
```

### Response Structure

The response contains data, errors, and metadata:

```elixir
%Chalk.Query.OnlineQueryResponse{
  data: [
    %Chalk.Query.FeatureResult{
      field: "user.id",
      value: 1,
      meta: %Chalk.Query.FeatureMeta{...}
    },
    %Chalk.Query.FeatureResult{
      field: "user.email",
      value: "user@example.com",
      meta: %Chalk.Query.FeatureMeta{...}
    },
    ...
  ],
  errors: [...],
  meta: %Chalk.Query.QueryMeta{...}
}
```

## Authentication

The Chalk client supports two authentication methods:

### Environment Variables

Set the following environment variables:

```
CHALK_CLIENT_ID=your_client_id
CHALK_CLIENT_SECRET=your_client_secret
```

Optionally, you can set a default deployment:

```
DEPLOYMENT_ID=your_deployment_id
```

### Explicit Credentials

Pass credentials directly to the client:

```elixir
Chalk.Query.online(
  %{
    inputs: %{
      "user.id": 1
    },
    outputs: [
      "user.id"
    ]
  },
  %{    
    client_id: "your_client_id",
    secret: "your_client_secret",
    deployment_id: "your_deployment_id" # Optional
  }
)
```

Credentials can be generated on the [Chalk dashboard](https://console.chalk.ai) or [via API](https://docs.chalk.ai/docs/online-authentication#fetching-an-access-token).

## Documentation

For detailed documentation, visit:
- [Hex docs](https://hexdocs.pm/chalk_elixir/)
- [Chalk API documentation](https://docs.chalk.ai/docs/query-basics)

## Development

### Running Tests

```bash
mix test
```

### Linting

```bash
mix dialyzer
mix credo
```

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.