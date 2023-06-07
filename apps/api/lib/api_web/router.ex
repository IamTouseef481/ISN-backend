defmodule ApiWeb.Router do
  use ApiWeb, :router
  @dialyzer {:no_return, call: 2}
  @dialyzer {:nowarn_function, call: 2}

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Api.GuardianHelper.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :admin_auth do
    plug Api.GuardianHelper.AdminAuth
  end

  #  Protected routes for Web Admin
  scope "/api/admin", ApiWeb do
    pipe_through [:api, :ensure_auth, :admin_auth]
    post "/invitation", UserController, :invitation
  end

  #  Non protected routes for Web Admin
  scope "/api/admin", ApiWeb do
    pipe_through [:api]
    post "/login", AuthenticationController, :login
    get "/exchange-token", AuthenticationController, :exchange_token
  end

  #  Non protected routes for mobile application
  scope "/api", ApiWeb do
    pipe_through [:api, :ensure_auth]
  end

  #  Protected routes for mobile application
  scope "/api", ApiWeb do
    pipe_through [:api]

    post "/login", AuthenticationController, :login
    post "/open_sign_up", UserController, :open_sign_up
    get "/users/confirm_email", UserController, :confirm_email
    get "/exchange-token", AuthenticationController, :exchange_token
  end

  scope "/api" do
    forward "/docs",
            PhoenixSwagger.Plug.SwaggerUI,
            otp_app: :api,
            disable_validator: true,
            swagger_file: "swagger.json"
  end
end
