defmodule Data.Context.UserRoles do
  import Ecto.Query, warn: false
  alias Data.Repo
  alias Data.Schema.UserRole

  @moduledoc false

  @type user_role() :: %UserRole{}
  @spec get_by(String.t()) :: list(user_role()) | []
  def get_by(user_id) do
    Repo.all(
      from ur in UserRole,
        where: ur.user_id == ^user_id
    )
  end
end
