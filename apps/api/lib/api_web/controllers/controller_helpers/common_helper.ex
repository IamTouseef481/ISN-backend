defmodule ApiWeb.ControllerHelpers.CommonHelper do
  import Ecto.Changeset

  @moduledoc false

  def format_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def random_string_of_length(length) do
    str = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890@!." |> String.split("")

    Enum.reduce(1..length, [], fn _i, acc ->
      [Enum.random(str) | acc]
    end)
    |> Enum.join("")
  end
end
