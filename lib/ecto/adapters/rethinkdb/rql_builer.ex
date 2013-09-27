defmodule Ecto.Adapters.Rethinkdb.RqlBuilder do
  use Rethinkdb

  alias Ecto.Query.Query
  alias Ecto.Query.QueryExpr
  alias Ecto.Query.Util
  alias Ecto.Query.Normalizer

  def pp(value), do: IO.inspect(value)

  def select(Query[] = query) do
    models = create_names(query)
    { rql, used_names } = from(query.from, models)

    select = select(query.select, models)
    rql.pluck(select)
  end

  defp select(expr, models) do
    QueryExpr[expr: expr] = Normalizer.normalize_select(expr)
    select_clause(expr, models)
  end

  defp expr({ :., _, [{ :&, _, [_] } = var, field] }, vars) when is_atom(field) do
    field
  end

  defp expr({ arg, _, [] }, vars) when is_tuple(arg) do
    expr(arg, vars)
  end

  defp select_clause({ :{}, _, elems }, vars) do
    Enum.map(elems, &select_clause(&1, vars))
  end

  defp select_clause({ x, y }, vars) do
    select_clause({ :{}, [], [x, y] }, vars)
  end

  defp select_clause(list, vars) when is_list(list) do
    Enum.map(list, &select_clause(&1, vars))
  end

  defp select_clause(expr, vars) do
    expr(expr, vars)
  end

  defp from(from, models) do
    name = tuple_to_list(models) |> Dict.fetch!(from)
    table = from.__model__(:name)
    { r.table(table), [name] }
  end

  defp create_names(query) do
    models = query.models |> tuple_to_list
    Enum.reduce(models, [], fn(model, names) ->
      table = model.__model__(:name) |> String.first
      name = unique_name(names, table, 0)
      [{ model, name }|names]
    end) |> Enum.reverse |> list_to_tuple
  end

  # Brute force find unique name
  defp unique_name(names, name, counter) do
    cnt_name = name <> integer_to_binary(counter)
    if Enum.any?(names, fn({ _, n }) -> n == cnt_name end) do
      unique_name(names, name, counter+1)
    else
      cnt_name
    end
  end
end
