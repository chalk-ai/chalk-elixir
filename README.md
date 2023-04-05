# chalk-elixir

[![Dialyxir](https://github.com/chalk-ai/chalk-elixir/actions/workflows/dialyxir.yaml/badge.svg)](https://github.com/chalk-ai/chalk-elixir/actions/workflows/dialyxir.yaml)
[![Integration tests](https://github.com/chalk-ai/chalk-elixir/actions/workflows/integration-test.yaml/badge.svg)](https://github.com/chalk-ai/chalk-elixir/actions/workflows/integration-test.yaml)
[![Publish to Hex](https://github.com/chalk-ai/chalk-elixir/actions/workflows/publish.yaml/badge.svg)](https://github.com/chalk-ai/chalk-elixir/actions/workflows/publish.yaml)

[![Hex.pm](https://img.shields.io/hexpm/v/chalk_elixir.svg)](https://hex.pm/packages/chalk_elixir)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/chalk_elixir/)
[![Hex.pm](https://img.shields.io/hexpm/dt/chalk_elixir.svg)](https://hex.pm/packages/chalk_elixir)
[![Hex.pm](https://img.shields.io/hexpm/dw/chalk_elixir.svg)](https://hex.pm/packages/chalk_elixir)

Elixir Client for Chalk [Online Queries](https://docs.chalk.ai/docs/query-basics).


## Usage

Online queries are executed by calling "Chalk.Query.online" and passing inputs and expected outputs as descibed in the [Chalk API documentation](https://docs.chalk.ai/docs/query-basics).

```
    Chalk.Query.online(%{
        inputs: %{
            "user.id": 1
        },
        outputs: [
            "user.id"
        ]
    })
```

## Authentication

The Chalk client uses authentication credentials set in the environment variables `CHALK_CLIENT_ID` and `CHALK_CLIENT_SECRET`.  
Credentials can be generated on the Chalk dashboard or [via api](https://docs.chalk.ai/docs/online-authentication#fetching-an-access-token.

The credentials can also be passed directly when invoking the client.

```
    Chalk.Query.online(%{
        inputs: %{
            "user.id": 1
        },
        outputs: [
            "user.id"
        ]
    }, %{    
        client_id: THE_CLIENT_ID,
        secret: THE_SECRET
    })
```