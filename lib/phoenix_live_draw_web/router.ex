defmodule PhoenixLiveDrawWeb.Router do
  use PhoenixLiveDrawWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PhoenixLiveDrawWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PhoenixLiveDrawWeb.SetPlayerIdPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixLiveDrawWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/me", MeController, only: [:update], singleton: true

    live "/room/:id", RoomLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixLiveDrawWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PhoenixLiveDrawWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
