defmodule Data.Schema.User do
  @moduledoc """
  The schema for a user
  """
  use Data.Schema
  #  import Bcrypt

  @type t :: %__MODULE__{
          id: binary,
          email: String.t() | nil,
          password: String.t() | nil,
          phone_number: String.t() | nil,
          status: String.t() | nil,
          deleted_by: binary | nil,
          auto_generate_pass: boolean | false,
          is_social_login: boolean | false
        }

  @required_fields ~w|
  password
  phone_number
  email
  |a

  @optional_fields ~w|
    status
    deleted_by
    auto_generate_pass
    is_social_login

  |a
  @filterable_fields ~w|
    status
    email
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "users" do
    field :email, :string
    field :password, :string
    field :phone_number, :string
    field :status, :string
    field :auto_generate_pass, :boolean, default: false
    field :is_social_login, :boolean, default: false
    has_one :person, Data.Schema.Person

    many_to_many :roles,
                 Data.Schema.Role,
                 join_through: "user_roles",
                 join_keys: [
                   user_id: :id,
                   role_id: :id
                 ],
                 on_replace: :delete

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> unique_constraint(:email)
    |> validate_length(:phone_number, max: 14)
    |> validate_format(:phone_number, ~r/^[0-9 # - +]*$/)
    |> put_password_hash()
  end

  def update_reviewer_pass_changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required([:password])
    |> put_password_hash()
  end

  def reset_password_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:password])
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{
           valid?: true,
           changes: %{
             password: password
           }
         } = changeset
       ) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  def filterable_fields, do: @filterable_fields
end
