defmodule Data.Schema.Role do
  @moduledoc """
  The schema for role
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary,
          title: String.t(),
          name: String.t(),
          deleted_by: binary
        }

  @required_fields ~w|


  |a

  @optional_fields ~w|
    title
    name
    deleted_by
  |a

  @filterable_fields ~w|
    name
    title
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "roles" do
    field :title, :string
    field :name, :string
    # belongs_to :deleted_by, Data.Schema.Person
    many_to_many :users, Data.Schema.User,
      join_through: "user_roles",
      join_keys: [role_id: :id, user_id: :id],
      on_replace: :delete

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def filterable_fields, do: @filterable_fields
end
