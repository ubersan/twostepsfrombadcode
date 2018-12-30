defmodule WebsiteWeb.WebglController do
  use WebsiteWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
