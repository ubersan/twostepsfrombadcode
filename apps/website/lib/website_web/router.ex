defmodule WebsiteWeb.Router do
  use WebsiteWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WebsiteWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/home", HomeController, :index
    get "/test", TestController, :index
    get "/webgl", WebglController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", WebsiteWeb do
  #   pipe_through :api
  # end
end
