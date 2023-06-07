defmodule Api.GuardianHelper.ErrorHandler do
  import Phoenix.Controller
  @moduledoc false

  def auth_error(conn, {type, _reason}, _opts) do
    return(conn, String.downcase(to_string(type)))
  end

  def auth_error(conn, error) do
    return(conn, String.downcase(to_string(error)))
  end

  defp return(conn, "unauthenticated") do
    json(conn, %{
      "error" => %{
        status: 401,
        message: "Unauthorized,To access this, you have to login to the system"
      }
    })
  end
end
