defmodule Ecto.Adapters.Rethinkdb do
  @moduledoc false

  # TODO: Make this module public and document the adapter options
  # This module handles the connections to the Postgres database with poolboy.
  # Each repository has their own pool.

  @behaviour Ecto.Adapter

  alias Rethinkdb.Rql
  alias Rethinkdb.Connection
  alias Ecto.Adapters.Rethinkdb.RqlBuilder
  alias Ecto.Query.Query

  defmacro __using__(_opts) do
    quote do
      def __rethinkdb__(:pool_name) do
        __MODULE__.Pool
      end
    end
  end

  @doc false
  def start(repo) do
    { pool_opts, worker_opts } = prepare_start(repo)
    :poolboy.start(pool_opts, worker_opts)
  end

  def start_link(repo) do
    { pool_opts, worker_opts } = prepare_start(repo)
    :poolboy.start_link(pool_opts, worker_opts)
  end

  def stop(repo) do
    pool_name = repo.__postgres__(:pool_name)
    :poolboy.stop(pool_name)
  end

  def all(repo, Query[] = query) do
    rql = RqlBuilder.rql(query)
    result = transaction(repo, rql)
  end

  @doc false
  def transaction(repo, rql) when is_record(rql, Rql) do
    :poolboy.transaction(repo.__rethinkdb__(:pool_name), fn(conn) ->
      rql.run({Connection, conn})
    end)
  end

  defp prepare_start(repo) do
    # Use :application.ensure_started for R16B01
    case :application.start(:rethinkdb) do
      :ok -> :ok
      { :error, { :already_started, _ } } -> :ok
      { :error, reason } ->
        raise "could not start :rethinkdb application, reason: #{inspect reason}"
    end

    pool_name   = repo.__rethinkdb__(:pool_name)
    worker_opts = Connection.Options.new(repo.url)

    pool_opts = [
      size: 5,
      max_overflow: 10,
      name: { :local, pool_name },
      worker_module: Connection ]

    { pool_opts, worker_opts }
  end
end
