defmodule WebsiteWeb.CubeController do
  use WebsiteWeb, :controller
  require Logger

  def index(conn, _params) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {'https://raw.githubusercontent.com/sandrohuber/twostepsfrombadcode/master/apps/website/assets/static/meshes/cube.obj', []}, [], [])

    str_body = to_string body
    all_lines = String.split(str_body, "\n")
    lines = Enum.filter(all_lines, fn line -> String.starts_with?(line, "v ") end)
    vectors = Enum.map(lines, fn line -> extract_position_vector(line) end)

    json conn, %{"cube" => vectors}
  end

  def extract_position_vector(line) do
    [_v, x, y, z] = String.split(line, "  ")
    %{"x" => String.to_float(x), "y" => String.to_float(y), "z" => String.to_float(z)}
  end
end
