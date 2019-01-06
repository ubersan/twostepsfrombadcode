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

    faces =
      body
      |> to_string
      |> String.split("\n")
      |> Enum.filter(fn line -> String.starts_with?(line, "f ") end)
      |> Enum.map(fn line -> extract_face(line) end)

    json conn, %{"mesh" => %{"vertices" => vertices, "faces" => faces}}
  end

  def extract_vertices(line) do
    [_v, x, y, z] = String.split(line, " ")
    %{"x" => String.to_float(x), "y" => String.to_float(y), "z" => String.to_float(z)}
  end

  def extract_face(line) do
    [_f, v1, v2, v3] = String.split(line, " ")
    %{"v1" => String.to_integer(v1), "v2" => String.to_integer(v2), "v3" => String.to_integer(v3)}
  end
end
