defmodule Data.Schema do
  @moduledoc """
  Imports all functionality for an ecto schema

  ### Usage

  ```
  defmodule Data.Schema.MySchema do
    use Data.Schema

    schema "my_schemas" do
      # Fields
    end
  end
  ```
  """
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Data.Schema
      import Ecto.Changeset

      @timestamps_opts [type: :utc_datetime]
    end
  end

  defmacro timestamp() do
    quote do
      field :deleted_at, :utc_datetime
      field :deleted_by, :string
      timestamps()
    end
  end
end
