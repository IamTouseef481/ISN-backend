defmodule Data.Schema.UserRole do
  @moduledoc """
  The schema for users roles
  """
  use Data.Schema

  @type t :: %__MODULE__{
          user_id: binary,
          role_id: binary
        }

  @required_fields ~w|
    user_id
    role_id
  |a

  @optional_fields ~w|
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "user_roles" do
    belongs_to :role, Data.Schema.Role
    belongs_to :user, Data.Schema.User
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
