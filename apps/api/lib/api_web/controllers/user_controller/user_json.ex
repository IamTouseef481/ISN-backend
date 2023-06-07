defmodule ApiWeb.UserJSON do
  @doc """
  Renders a list of urls.
  """
  def invitation(%{status: message}) do
    %{success: message}
  end

  def error_response(%{status: code, error: error}) do
    %{status: code, errors: error}
  end

  def response(msg \\ "", data \\ %{}, status \\ 200) do
    %{message: msg, data: data, status: status}
  end

  def other_error_response(message, status \\ 200) do
    %{error: %{status: status, message: message}}
  end
end
