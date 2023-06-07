defmodule Data.Context.Users do
  import Ecto.Query, warn: false
  @repo Data.Repo
  import Sage
  alias Data.Schema.{User, Person}
  alias Data.Context

  @moduledoc false

  def users_list() do
    @repo.all(
      from u in User,
        left_join: r in assoc(u, :roles),
        preload: [roles: r],
        order_by: [asc: u.name]
    )
  end

  def get_user(id) do
    @repo.one(
      from u in User,
        left_join: r in assoc(u, :roles),
        preload: [roles: r],
        where: u.id == ^id
    )
  end

  def get_user_by(%{"email" => email}), do: @repo.get_by(User, email: email)

  def get_user_by(%{"phone_number" => phone_number}),
    do: @repo.get_by(User, phone_number: phone_number)

  def get_user_by(), do: nil

  def authenticate_user(email, plain_text_password) do
    query = from u in User, where: u.email == ^email

    case @repo.one(query) do
      nil ->
        {:error, "invalid email"}

      user ->
        if user.password && Argon2.verify_pass(plain_text_password, user.password) do
          {:ok, user}
        else
          {:error, "invalid password"}
        end
    end
  end

  #  @spec add_roles(map(), map()) :: {:ok, map()} | {:error, any()}
  #  defp add_roles(%{user: user}, attrs) do
  #
  #    {
  #      Enum.each(attrs["roles"], &Context.create(UserRole, %{"user_id" => user.id, "role_id" => &1})),
  #      %{}
  #    }
  #
  #  end

  def all_user_list(model) do
    @repo.all(model) |> @repo.preload(:roles)
  end

  @spec query() :: Ecto.Queryable.t()
  defp query() do
    from u in User,
      where: is_nil(u.deleted_at)
  end

  @type user_struct() :: %User{}
  @type changeset() :: %Ecto.Changeset{}
  @spec get_by(String.t()) :: user_struct() | nil
  def get_by(email), do: @repo.get_by(query(), email: email)

  @spec reset_password(user_struct(), map()) :: {:ok, user_struct()} | {:error, changeset()}
  def reset_password(%User{} = user, attrs) do
    user
    |> User.reset_password_changeset(attrs)
    |> @repo.update()
  end

  def user_open_sign_up(attrs) do
    new()
    |> run(:user, &create_user/2)
    |> run(:person, &create_person/2)
    |> transaction(@repo, attrs)
  end

  defp create_user(_, %{"user" => attrs}) do
    Context.create(User, attrs)
  end

  defp create_user(_, _) do
    {:ok, %{}}
  end

  defp create_person(map, %{"person" => attrs}) do
    params =
      Map.merge(
        attrs,
        %{
          "user_id" => Map.get(map.user, :id)
        }
      )

    Context.create(Person, params)
  end

  defp create_person(_, _) do
    {:ok, %{}}
  end
end
