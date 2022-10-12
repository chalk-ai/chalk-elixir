defmodule Chalk.Common do
  defmodule ChalkException do
    defstruct kind: nil, message: nil, stacktrace: nil

    @type t :: %__MODULE__{
            kind: String.t(),
            message: String.t(),
            stacktrace: String.t()
          }
  end

  defmodule ChalkError do
    defstruct code: nil, category: nil, message: nil, exception: nil, feature: nil, resolver: nil

    @type t :: %__MODULE__{
            code: String.t(),
            category: String.t(),
            message: String.t(),
            exception: ChalkException.t(),
            feature: String.t(),
            resolver: String.t()
          }
  end
end
