defmodule Data.Schema.Person do
  @moduledoc """
  The schema for a Person
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          secondary_email: String.t() | nil,
          secondary_phone_number: String.t() | nil,
          gender: String.t() | nil,
          address: String.t() | nil,
          city: String.t() | nil,
          state: String.t() | nil,
          country: String.t() | nil,
          zip_code: String.t() | nil,
          deleted_by: binary,
          user_id: binary
        }

  @required_fields ~w|
  first_name
  last_name
  |a

  @optional_fields ~w|
    secondary_email
    secondary_phone_number
    gender
    address
    city
    state
    country
    zip_code
    deleted_by
    user_id
  |a
  @filterable_fields ~w|
  first_name
  last_name
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "persons" do
    field :first_name, :string
    field :last_name, :string
    field :secondary_email, :string
    field :secondary_phone_number, :string
    field :address, :string
    field :city, :string
    field :country, :string
    field :state, :string
    field :gender, :string
    field :zip_code, :string
    belongs_to :user, Data.Schema.User
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> validate_format(:first_name, ~r/^[A-Za-zÀ-ú ü ñ ¿ ¡ ]+$/)
    |> validate_format(:last_name, ~r/^[A-Za-zÀ-ú ü ñ ¿ ¡ ]+$/)
    |> validate_length(:first_name, max: 255)
    |> validate_length(:last_name, max: 255)
    |> validate_length(:address, max: 255)
  end

  def filterable_fields, do: @filterable_fields
end
