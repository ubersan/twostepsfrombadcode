defmodule WebsiteWeb.CubeController do
  use WebsiteWeb, :controller

  def index(conn, _params) do
    json conn, %{"user" => %{"id" => 123, "name" => "Lenu van de Brenu"}}
  end
end
