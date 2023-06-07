defmodule ApiWeb.UserController do
  @moduledoc false
  use ApiWeb, :controller
  use PhoenixSwagger
  alias Data.Schema.{User}
  alias Data.Context
  alias Data.Context.Users
  alias ApiWeb.ControllerHelpers.CommonHelper

  def invitation(conn, params) do
    if params["email"] != "" || params["phone"] != nil do
      _res =
        if params["email"] != nil && params["email"] != "" do
          create_user(conn, params)
        else
          conn
          |> render(
            :error_response,
            %{
              status: 400,
              error: "Phone service Currently not available"
            }
          )
        end

      conn
    else
      conn
      |> render(:error_response, %{status: 400, error: "Missing Compulsory Fields"})
    end
  end

  def open_sign_up(conn, params) do
    params = put_in(params, ["user", "status"], "pending")

    case Users.user_open_sign_up(params) do
      {:ok, _, %{user: user, person: _person}} ->
        token = Phoenix.Token.sign(ApiWeb.Endpoint, "user auth", user.id)
        base = Application.get_env(:api, Api.Mailer)[:email_confirmation_base_url]

        html_body =
          "Hi,we just need to verify your email address.
                  <p>Click below to confirm your email address: </p>,
                  <p> <a href='#{base}api/users/confirm_email?token=#{token}'>Confirm Email Address</a></p>"

        {:ok, _} =
          Task.start(fn ->
            Api.Mailer.Email.mail_invitation_to_user(user.email, "Confirmation Email", html_body)
          end)

        conn
        |> json(
          ApiWeb.UserJSON.response(%{
            msg: "A Confirmation email is sent to your email address. Please Verify Your Email!"
          })
        )

      {:error, changeset} ->
        conn
        |> render(:error_response, %{status: 400, error: CommonHelper.format_errors(changeset)})
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    if token == "" || token == nil do
      conn
      |> json(ApiWeb.UserJSON.other_error_response("token field cannot be empty."))
    else
      case Phoenix.Token.verify(ApiWeb.Endpoint, "user auth", token, max_age: 86_400) do
        {:ok, id} ->
          user = Context.get!(User, id)
          {:ok, _} = Context.update(User, user, %{"status" => "active"})

          conn
          |> json(
            ApiWeb.UserJSON.response(%{
              msg: " Welcome to the System your Email is successfully verified."
            })
          )

        {:error, reason} ->
          conn
          |> json(ApiWeb.UserJSON.other_error_response(reason))
      end
    end
  end

  defp create_user(conn, user_params) do
    password = CommonHelper.random_string_of_length(12)
    params = Map.merge(user_params, %{"password" => password, "status" => "pending"})

    case Context.create(User, params) do
      {:ok, user} ->
        html_body = "Please enter credentials to Update your Password and login in the app
                  <p> email: #{user.email}</p>,
                  <p> password: #{password}</p>"

        case Api.Mailer.Email.mail_invitation_to_user(user.email, "Invitation for App", html_body) do
          {:ok, _} ->
            {_, _} =
              Api.Worker.schedule(%{
                email: user.email,
                scheduled_at: DateTime.add(DateTime.utc_now(), 48, :hour)
              })

            conn
            |> put_status(:ok)
            |> render(:invitation, %{status: "Invite Sent successfully."})

          {:error, _} ->
            conn
            |> put_status(400)
            |> render(:error_response, %{status: 400, error: "Failed to send mail"})
        end

      {:error, changeset} ->
        errors = CommonHelper.format_errors(changeset)

        conn
        |> put_status(400)
        |> render(:error_response, %{status: 400, error: errors})
    end
  end

  def swagger_definitions do
    %{
      Person:
        swagger_schema do
          title("Person")
          description("Person")
        end,
      UserToken:
        swagger_schema do
          title("Confirm email using token")
          description("Confirm email using token ")

          properties do
            token(:string, "token")
          end

          example(%{
            token:
              "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhcGkiLCJleHAiOjE2ODU5NjY3NjMsImlhdCI6MTY4NTk2MzE2MywiaXNzIjoiYXBpIiwianRpIjoiNTRjYzJhNDctNjQzYy00NDE1LTk4ODYtMmU2YWJkYmM0NDhmIiwibmJmIjoxNjg1OTYzMTYyLCJzdWIiOiIxIiwidHlwIjoiYWNjZXNzIn0._Dnuoiy5QTFJUfrn9q6uCkCDznL1XAKYskeoy9g22OTD2yvvd0g2ArvETypHu7To0G_bG3Rr3skt2EmNPGsNSQ"
          })
        end,
      Invite:
        swagger_schema do
          title("User Info for Invitation")

          description(
            "Invite to the System via Email or Phone number, One of them is compulsory for Invitation"
          )

          properties do
            email(:string, "email")
            phone(:integer, "phone_number")
          end

          example(%{
            email: "admin@admin.com",
            phone: "+92 (944)-135-2451"
          })
        end,
      user_open_sign_up:
        swagger_schema do
          title("User Sign Up")
          description("A new user can register itself in the system by signing up.")

          properties do
            first_name(:string, "first_name", required: true)
            last_name(:string, "last_name", required: true)
            address(:string, "address")
            email(:string, "email address", required: true)
            phone_number(:string, "phone_number", required: true)
            city(:string, "city")
            state(:string, "state")
            country(:string, "country")
            zip_code(:string, "zip_code")
            password(:string, "new password", required: true)
          end

          example(%{
            "person" => %{
              "first_name" => "testt",
              "last_name" => "user",
              "address" => "Tanbits, Lahore",
              "city" => "Lahore",
              "state" => "Punjab",
              "country" => "Pakistan",
              "zip_code" => "5676"
            },
            "user" => %{
              "email" => "testtuser@gmail.com",
              "phone_number" => "+92 (944)-135-2451",
              "password" => "12345"
            }
          })
        end
    }
  end

  swagger_path :invitation do
    post("/invitation")
    produces("application/json")
    security([%{Bearer: []}])
    description("Used to sign up for App using Mobile or Email.")

    parameters do
      body(
        :body,
        Schema.ref(:Invite),
        "Sign Up to the System via Email or Phone number, One of them is compulsory for Invitation",
        required: true
      )
    end

    response(200, "Ok")
    response(404, "Not found")
    response(400, "Missing Compulsory Fields")
  end

  swagger_path :open_sign_up do
    post("/open_sign_up")
    produces("application/json")
    security([%{Bearer: []}])
    description("A new user can register itself in the system by signing up.")

    parameters do
      body(
        :body,
        Schema.ref(:user_open_sign_up),
        "Sign Up to the System, first_name, last_name, email, phone_number and password fields are compulsory",
        required: true
      )
    end

    response(200, "Ok")
    response(409, "Conflict")
    response(400, "Missing Compulsory Fields")
  end

  swagger_path :confirm_email do
    get("/users/confirm_email")
    summary("Confirm user email for sign up purpose.")
    description("Confirm user email for sign up purpose")
    produces("application/json")

    parameters do
      token(:query, :string, "Token", required: true)
    end

    response(200, "Ok", Schema.ref(:UserToken))
    response(404, "Not found")
    response(400, "Missing Compulsory Fields")
  end
end
