defmodule Data.Context.Roles do
  import Ecto.Query, warn: false
  alias Data.Repo
  alias Data.Schema.Role

  @moduledoc false

  @type role() :: %Role{}
  @spec get_by(String.t()) :: role() | nil
  def get_by(role_name), do: Repo.one(from r in Role, where: r.name == ^role_name)

  def role_list() do
    from(r in Role,
      select: %{id: r.id, name: r.name}
    )
    |> Repo.all()
  end
end
