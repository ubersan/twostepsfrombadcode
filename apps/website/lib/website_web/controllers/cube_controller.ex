defmodule WebsiteWeb.CubeController do
  use WebsiteWeb, :controller
  require Logger

  def index(conn, _params) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {'https://raw.githubusercontent.com/sandrohuber/twostepsfrombadcode/master/apps/website/assets/static/meshes/cube.obj', []}, [], [])

    vertices =
      body
      |> to_string
      |> String.split("\n")
      |> Enum.filter(fn line -> String.starts_with?(line, "v ") end)
      |> Enum.map(fn line -> extract_vertices(line) end)

    json conn, %{"cube" => %{"vertices" => vertices}}
  end

  def extract_vertices(line) do
    [_v, x, y, z] = String.split(line, " ")
    %{"x" => String.to_float(x), "y" => String.to_float(y), "z" => String.to_float(z)}
  end
end
