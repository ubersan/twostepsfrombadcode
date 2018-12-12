defmodule TwostepsfromcodeWeb.PageController do
  use TwostepsfromcodeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
