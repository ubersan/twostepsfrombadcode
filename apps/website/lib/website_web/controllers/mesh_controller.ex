defmodule WebsiteWeb.MeshController do
  use WebsiteWeb, :controller
  require Logger

  def index(conn, %{"mesh_name" => mesh_name}) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {to_charlist("https://raw.githubusercontent.com/sandrohuber/twostepsfrombadcode/master/apps/website/assets/static/meshes/" <> mesh_name <> ".obj"), []}, [], [])

    lines =
      body
      |> to_string
      |> String.split("\n")

    raw_vertices =
      lines
      |> Enum.filter(&String.starts_with?(&1, "v "))
      |> Enum.map(&extract_vertex/1)
    
    vertices = centralices_vertices(raw_vertices)

    normals =
      lines
      |> Enum.filter(&String.starts_with?(&1, "vn "))
      |> Enum.map(&extract_normals/1)

    triangles = 
      lines
      |> Enum.filter(&String.starts_with?(&1, "f "))
      |> Enum.map(&extract_face/1)
      |> Enum.map(&map_face_to_vertex(&1, vertices, normals))

    json conn, %{"mesh" => %{"triangles" => triangles}}
  end

  def centralices_vertices(vertices) do
    number_of_vertices = Enum.count(vertices)
    tester =
      (vertices
      |> Enum.map(&Map.fetch!(&1, "z"))
      |> Enum.sum
      ) / number_of_vertices
      

    Logger.info inspect(tester)

    mu_x = (vertices |> Enum.map(&Map.fetch!(&1, "x")) |> Enum.sum) / number_of_vertices
    mu_y = (vertices |> Enum.map(&Map.fetch!(&1, "y")) |> Enum.sum) / number_of_vertices
    mu_z = (vertices |> Enum.map(&Map.fetch!(&1, "z")) |> Enum.sum) / number_of_vertices

    vertices
      |> Enum.map(fn vertex -> %{"x" => vertex["x"] - mu_x, "y" => vertex["y"] - mu_y, "z" => vertex["z"] - mu_z} end)
  end

  def map_face_to_vertex(face, vertices, normals) do
    triangle = face |> Enum.map(&Enum.at(vertices, &1["vertex"] - 1))
    normal = face |> Enum.map(&Enum.at(normals, &1["normal"] - 1))
    Enum.reduce([1, 2, 3], %{}, fn x, acc -> Map.put(acc, "v" <> Integer.to_string(x), Map.merge(Enum.at(triangle, x - 1), Enum.at(normal, x - 1))) end)
  end

  def extract_vertex(line) do
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
