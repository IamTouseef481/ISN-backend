defmodule Api.GuardianHelper.Guardian do
  use Guardian, otp_app: :api

  alias Data.Context
  alias Data.Schema.User

  @moduledoc false

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Context.get!(User, id) |> Context.preload_selective([:person, :roles])
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
