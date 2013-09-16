ExUnit.start

defmodule EctoRethinkdb.Case do
  use ExUnit.CaseTemplate

  using _ do
    quote do
      import unquote(__MODULE__)
    end
  end

  # Debug in tests
  def pp(value), do: IO.inspect(value)
end
