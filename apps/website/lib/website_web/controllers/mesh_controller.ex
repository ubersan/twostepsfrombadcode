defmodule WebsiteWeb.MeshController do
  use WebsiteWeb, :controller
  require Logger

  def index(conn, %{"mesh_name" => mesh_name}) do
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

    normals =
      body
      |> to_string
      |> String.split("\n")
      |> Enum.filter(fn line -> String.starts_with?(line, "vn ") end)
      |> Enum.map(fn line -> extract_normals(line) end)

    triangles = Enum.map(faces, fn face -> map_face_to_vertex(face, vertices, normals) end)

    json conn, %{"mesh" => %{"triangles" => triangles}}
  end

  def map_face_to_vertex(face, vertices, normals) do
    triangle = face |> Enum.map(fn f -> Enum.at(vertices, f["vertex"] - 1) end)
    normal = face |> Enum.map(fn f -> Enum.at(normals, f["normal"] - 1) end)
    Enum.reduce([1, 2, 3], %{}, fn x, acc -> Map.put(acc, "v" <> Integer.to_string(x), Map.merge(Enum.at(triangle, x - 1), Enum.at(normal, x - 1))) end)
  end

  def extract_vertices(line) do
    [_v, x, y, z] = String.split(line, " ")
    %{"x" => String.to_float(x), "y" => String.to_float(y), "z" => String.to_float(z)}
  end

  def extract_normals(line) do
    [_v, x, y, z] = String.split(line, " ")
    %{"nx" => String.to_float(x), "ny" => String.to_float(y), "nz" => String.to_float(z)}
  end

  def extract_face(line) do
    [_f, f1, f2, f3] = String.split(line, " ")
    [f1, f2, f3]
      |> Enum.map(fn face -> String.split(face, "/") end)
      |> Enum.map(fn indices -> %{"vertex" => String.to_integer(Enum.at(indices, 0)), "normal" => String.to_integer(Enum.at(indices, 2))} end)
  end
end
