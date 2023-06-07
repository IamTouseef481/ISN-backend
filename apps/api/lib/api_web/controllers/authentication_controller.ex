defmodule ApiWeb.AuthenticationController do
  @moduledoc """
  Manage Authentication things for users.
  """

  # ============================================================================
  # Uses, Requires, Aliases
  # ============================================================================
  use ApiWeb, :controller

  alias Api.GuardianHelper.Guardian
  alias Data.Context.Users
  alias Data.Schema.User
  use PhoenixSwagger

  # ----------------------------------------------------------------------------
  # login\2
  # ----------------------------------------------------------------------------
  swagger_path :login do
    post("/login")
    summary("Access the system by logging in.")

    description(
      "You have the option to log in using either your valid email address or mobile phone number."
    )

    produces("application/json")

    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:Login), "Login Credentials", required: true)
    end

    response(200, "Ok", Schema.ref(:User))
    response(404, "Not found")
    response(400, "Missing Compulsory Fields")
  end

  def login(conn, %{"password" => password} = params) do
    with data when not is_nil(data) <- params["email"] || params["phone_number"],
         %User{} = user <- Users.get_user_by(params),
         {:ok, :success} <- check_password(user.password, password),
         {:ok, user_data} <- user |> put_token() do
      user_data =
        user_data
        |> Map.from_struct()
        |> Map.drop([:__meta__, :person, :roles])

      render(conn, :login, %{user: user_data})
    else
      nil -> render(conn, :error, %{error: ["Invalid Email or Password"]})
      {:error, error} -> render(conn, :error, %{error: error})
      {:not_exist, error} -> render(conn, :error, %{error: error})
    end
  end

  defp put_token(user) do
    with {:ok, access_token, _} <-
           Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {12, :hour}),
         {:ok, refresh_token, _} <-
           Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {1, :weeks}) do
      user = Map.merge(user, %{access_token: access_token, refresh_token: refresh_token})
      {:ok, user}
    else
      _ -> {:error, ["Something Went Wrong"]}
    end
  end

  defp check_password(hash_password, plain_password) do
    case Argon2.verify_pass(plain_password, hash_password) do
      true -> {:ok, :success}
      _ -> {:not_exist, ["Invalid password"]}
    end
  end

  # ----------------------------------------------------------------------------
  # create_new_token\2
  # ----------------------------------------------------------------------------
  swagger_path :exchange_token do
    get("/exchange-token")

    summary(
      "The purpose of this API is to generate a access token using a refresh token. This new access token can be utilized for logging into the system."
    )

    description(
      "This API allows you to obtain a new access token whenever the current one expires. With the new access token, you can log in to the system again."
    )

    produces("application/json")

    parameters do
      refresh_token(:query, :string, "Refresh Token", required: true)
      # refresh_token(:query, :refresh_token, "Refresh Token")
    end

    response(200, "Ok", Schema.ref(:Token))
    response(404, "Not found")
    response(400, "Missing Compulsory Fields")
  end

  @doc """
  Return list of frequently asked questions.
  """
  def exchange_token(conn, %{"refresh_token" => refresh_token}) do
    case Api.GuardianHelper.Guardian.exchange(refresh_token, "refresh", "access", ttl: {12, :hour}) do
      {:ok, {refresh_token, _}, {access_token, _}} ->
        render(conn, :new_token, %{
          token: %{access_token: access_token, refresh_token: refresh_token}
        })

      {:error, _} ->
        render(conn, :error, %{error: ["Something Went Wrong"]})
    end
  end

  def swagger_definitions do
    %{
      User:
        swagger_schema do
          title("User")
          description("User")

          properties do
            email(:string, "email")
            password(:string, "password")
          end

          example(%{
            id: 1,
            email: "superadmin123@admin.com",
            password: "12345",
            access_token:
              "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhcGkiLCJleHAiOjE2ODU5NjY3NjMsImlhdCI6MTY4NTk2MzE2MywiaXNzIjoiYXBpIiwianRpIjoiNTRjYzJhNDctNjQzYy00NDE1LTk4ODYtMmU2YWJkYmM0NDhmIiwibmJmIjoxNjg1OTYzMTYyLCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0._Dnuoiy5QTFJUfrn9q6uCkCDznL1XAKYskeoy9g22OTD2yvvd0g2ArvETypHu7To0G_bG3Rr3skt2EmNPGsNSQ",
            refresh_token:
              "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhcGkiLCJleHAiOjE2ODU5NzAzNjMsImlhdCI6MTY4NTk2MzE2MywiaXNzIjoiYXBpIiwianRpIjoiYjRlNmU4N2YtYTYwZi00OGZhLWJlZWYtYWRkNzEzY2ExZjI0IiwibmJmIjoxNjg1OTYzMTYyLCJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCJ9.v8S7_1CrxZfYMDcuj8FHeB5_bjtTU7O4fm04P8JtuG952UHno8nOis1dj2EuMS0x1vo-QIYsghrU3XzKLe3pTg"
          })
        end,
      Login:
        swagger_schema do
          title("Access the system by logging in.")

          description(
            "You have the option to log in using either your valid email address or mobile phone number."
          )

          properties do
            email(:string, "email")
            password(:string, "password")
          end

          example(%{
            email: "superadmin@isn.com",
            password: "kdjNncjd@847987"
          })
        end,
      Token:
        swagger_schema do
          title("This API is used to create new access token from refresh token")

          description(
            "Every time when access token got expired wo can use this API to re_new the access_token. By using this new access token you can login to the system."
          )

          properties do
            access_token(:string, "Access Token")
            refresh_token(:string, "Refresh Token")
          end

          example(%{
            access_token:
              "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhcGkiLCJleHAiOjE2ODU5NjY3NjMsImlhdCI6MTY4NTk2MzE2MywiaXNzIjoiYXBpIiwianRpIjoiNTRjYzJhNDctNjQzYy00NDE1LTk4ODYtMmU2YWJkYmM0NDhmIiwibmJmIjoxNjg1OTYzMTYyLCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0._Dnuoiy5QTFJUfrn9q6uCkCDznL1XAKYskeoy9g22OTD2yvvd0g2ArvETypHu7To0G_bG3Rr3skt2EmNPGsNSQ",
            refresh_token:
              "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhcGkiLCJleHAiOjE2ODU5NzAzNjMsImlhdCI6MTY4NTk2MzE2MywiaXNzIjoiYXBpIiwianRpIjoiYjRlNmU4N2YtYTYwZi00OGZhLWJlZWYtYWRkNzEzY2ExZjI0IiwibmJmIjoxNjg1OTYzMTYyLCJzdWIiOiIxIiwidHlwIjoicmVmcmVzaCJ9.v8S7_1CrxZfYMDcuj8FHeB5_bjtTU7O4fm04P8JtuG952UHno8nOis1dj2EuMS0x1vo-QIYsghrU3XzKLe3pTg"
          })
        end
    }
  end
end
