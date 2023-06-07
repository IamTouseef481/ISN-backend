defmodule Api.Mailer.Email do
  @moduledoc """
    Module as Email Helper
  """
  import Bamboo.Email

  def mail_invitation_to_user(to, subject, html_body) do
    new_email(
      to: to,
      from: Application.get_env(:api, Api.Mailer)[:username],
      subject: subject,
      html_body: html_body
    )
    |> put_header("Reply-To", Application.get_env(:api, Api.Mailer)[:username])
    |> Api.Mailer.deliver_now()
  end
end
