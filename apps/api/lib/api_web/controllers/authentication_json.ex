defmodule ApiWeb.AuthenticationJSON do
  @moduledoc false

  def login(%{user: user}) do
    %{
      id: user.id,
      email: user.email,
      access_token: user.access_token,
      refresh_token: user.refresh_token
    }
  end

  def new_token(%{token: token}), do: token

  def error(%{error: error}), do: %{error: error}
end
