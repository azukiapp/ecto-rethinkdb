defmodule Ecto.Adapters.Rethinkdb.RqlBuilder do
  use Rethinkdb

  alias Ecto.Query.Query

  def rql(Query[] = query) do
    r.expr([1, 2, 2])
  end
end
