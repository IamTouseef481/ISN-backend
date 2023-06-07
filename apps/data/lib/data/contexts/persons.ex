defmodule Data.Context.Persons do
  import Ecto.Query, warn: false
  @repo Data.Repo

  @moduledoc false

  alias Data.Schema.{Person, User, UserRole}

  def person_name_list() do
    @repo.all(
      from p in Person,
        select: %{
          id: p.id,
          name: fragment("concat(?, ' ', ?)", p.first_name, p.last_name)
        }
    )
  end

  def person_email_list() do
    @repo.all(
      from p in Person,
        select: %{
          id: p.id,
          email: p.email_address
        }
    )
  end

  def search_on_key(key) do
    if key && key != "" do
      key_ =
        key
        |> String.downcase()
        |> String.trim()

      key = "%#{key_}%"

      dynamic(
        [p],
        like(fragment("lower(concat(?,' ', ?))", p.first_name, p.last_name), ^key)
      )
    else
      true
    end
  end

  def get_by(user_id) do
    @repo.all(
      from ur in UserRole,
        where: ur.user_id == ^user_id
    )
  end

  @type user_struct() :: %User{}
  @type changeset() :: %Ecto.Changeset{}
  @spec reset_password(user_struct(), map()) :: {:ok, user_struct()} | {:error, changeset()}
  def reset_password(user, attrs) do
    user
    |> User.reset_password_changeset(attrs)
    |> @repo.update()
  end
end
