defmodule Api.Worker do
  @moduledoc false
  use Oban.Worker, queue: __MODULE__, max_attempts: 3
  require Logger

  def schedule(
        %{
          email: _,
          scheduled_at: time
        } = args
      ) do
    args
    |> __MODULE__.new(scheduled_at: time)
    |> Oban.insert()
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "email" => email,
          "scheduled_at" => _
        }
      }) do
    user = Data.Context.Users.get_user_by(%{"email" => email})

    if user && user.status != "complete" do
      html_body =
        "Invitation email has already been sent, Please check your mail and complete sign up Info for optional fields
                  <p> incase of email not received check your spam or contact admin </p>"

      Api.Mailer.Email.mail_invitation_to_user(email, "Reminder - Invitation for App", html_body)
    end
  end
end
