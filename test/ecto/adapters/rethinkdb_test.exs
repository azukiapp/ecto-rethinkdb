defmodule Ecto.Adapters.Rethinkdb.Test do
  use EctoRethinkdb.Case
  use Rethinkdb

  import Ecto.Query

  defmodule Repo do
    use Ecto.Repo, adapter: Ecto.Adapters.Rethinkdb

    def url do
      "rethinkdb://localhost/repo"
    end
  end
end
