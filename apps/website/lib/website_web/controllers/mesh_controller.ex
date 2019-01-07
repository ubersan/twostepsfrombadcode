defmodule WebsiteWeb.MeshController do
  use WebsiteWeb, :controller
  require Logger

  def index(conn, %{"mesh_name" => mesh_name}) do
    Logger.info mesh_name

    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {to_charlist("https://raw.githubusercontent.com/sandrohuber/twostepsfrombadcode/master/apps/website/assets/static/meshes/" <> mesh_name <> ".obj"), []}, [], [])

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

    vertices2 =
      body
      |> to_string
      |> String.split("\n")
      |> Enum.filter(fn line -> String.starts_with?(line, "v ") end)
      |> Enum.map(fn line -> extract_vertices2(line) end)

    faces2 =
      body
      |> to_string
      |> String.split("\n")
      |> Enum.filter(fn line -> String.starts_with?(line, "f ") end)
      |> Enum.map(fn line -> extract_face2(line) end)

    triangles = Enum.map(faces2, fn face -> map_face_to_vertex(face, vertices2) end)

    json conn, %{"mesh" => %{"vertices" => vertices, "faces" => faces, "triangles" => triangles}}
  end

  def extract_vertices(line) do
    [_v, x, y, z] = String.split(line, " ")
    %{"x" => String.to_float(x), "y" => String.to_float(y), "z" => String.to_float(z)}
  end

  def extract_face(line) do
    [_f, v1, v2, v3] = String.split(line, " ")
    %{"v1" => String.to_integer(v1), "v2" => String.to_integer(v2), "v3" => String.to_integer(v3)}
  end

  def map_face_to_vertex(face, vertices) do
    triangle = face |> Enum.map(fn vi -> Enum.at(vertices, vi - 1) end)
    Enum.reduce([1, 2, 3], %{}, fn x, acc -> Map.put(acc, "v" <> Integer.to_string(x), Enum.at(triangle, x - 1)) end)
  end

  def extract_vertices2(line) do
    [_v, x, y, z] = String.split(line, " ")
    #[String.to_float(x), String.to_float(y), String.to_float(z)]
    %{"x" => String.to_float(x), "y" => String.to_float(y), "z" => String.to_float(z)}
  end

  def extract_face2(line) do
    [_f, v1, v2, v3] = String.split(line, " ")
    [String.to_integer(v1), String.to_integer(v2), String.to_integer(v3)]
  end
end
