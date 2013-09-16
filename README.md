# Rethinkdb adapter for Ecto

This is a simple adapter to use [Rethinkdb](http://rethinkdb.com) in [Ecto](https://github.com/elixir-lang/ecto).

## Installation

Add the following to your list of dependencies in mix.exs:

```elixir
{ :'ecto-rethinkdb', github: "azukiapp/ecto-rethinkdb" }
```

## Usage

```elixir
defmodule Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Rethinkdb

  def url do
    "rethinkdb://localhost/ecto_simple"
  end
end

defmodule Weather do
  use Ecto.Model

  queryable "weather" do
    field :city,    :string
    field :temp_lo, :integer
    field :temp_hi, :integer
    field :prcp,    :float, default: 0.0
  end
end

defmodule Simple do
  import Ecto.Query

  def sample_query do
    query = from w in Weather,
          where: w.prcp > 0 or w.prcp == nil,
         select: w
    Repo.all(query)
  end
end
```

## License

"Azuki" and the Azuki logo are copyright (c) 2013 Azuki Serviços de Internet LTDA..

Rethinkdb Ecto Adapter source code is released under Apache 2 License.

Check LEGAL and LICENSE files for more information.
