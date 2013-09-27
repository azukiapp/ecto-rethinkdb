defmodule Ecto.Adapters.Rethinkdb.RqlBuilder.Test do
  use EctoRethinkdb.Case
  use Rethinkdb

  import Ecto.Query
  import Ecto.Query.Util, only: [normalize: 1]
  alias Ecto.Adapters.Rethinkdb.RqlBuilder

  defmodule Model do
    use Ecto.Model

    queryable "model" do
      field :x, :integer
      field :y, :integer
    end
  end

  defmodule Comment do
    use Ecto.Model

    queryable "comments" do
      field :text, :string
      belongs_to :post, Ecto.Adapters.Rethinkdb.RqlBuilder.Test.Post
    end
  end

  defmodule Post do
    use Ecto.Model

    queryable "posts" do
      field :title, :string
      has_many :comments, Ecto.Adapters.Rethinkdb.RqlBuilder.Test.Comment
    end
  end

  test "from" do
    query = from(Model) |> select([m], m.x) |> normalize
    rql   = r.table("model").pluck("x").build
    assert RqlBuilder.select(query).build == rql
  end

  test "select" do
    query  = from(Model) |> select([r], {r.x, r.y}) |> normalize
    rql    = r.table("model").pluck(["x", "y"]).build
    assert RqlBuilder.select(query).build == rql
  end
end
