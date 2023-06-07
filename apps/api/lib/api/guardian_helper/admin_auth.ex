defmodule Api.GuardianHelper.AdminAuth do
  @moduledoc """
    Plug for admin auth
  """
  def init(default), do: default

  def call(conn, _params) do
    conn
  end
end
