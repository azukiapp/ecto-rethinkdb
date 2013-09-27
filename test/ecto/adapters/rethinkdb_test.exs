defmodule Ecto.Adapters.Rethinkdb.Test do
  use EctoRethinkdb.Case
  use Rethinkdb

  #import Ecto.Query

  defmodule Repo do
    use Ecto.Repo, adapter: Ecto.Adapters.Rethinkdb

    def url do
      "rethinkdb://localhost/repo"
    end
  end

  test "stores pool_name metadata" do
    assert Repo.__rethinkdb__(:pool_name) == __MODULE__.Repo.Pool
  end

  test "start a link" do
    {:ok, _} = Repo.start_link

    :poolboy.transaction(__MODULE__.Repo.Pool, fn(conn) ->
      conn = {Rethinkdb.Connection, conn}
      assert [1, 2, 3] == r.expr([1, 2, 3]).run!(conn)
    end)

    assert :ok == Repo.stop
  end
end
