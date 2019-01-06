module Home exposing (main)

import Browser
import Browser.Events exposing (onAnimationFrameDelta)

import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style, width, height)
import Http
import Json.Decode exposing (Decoder, map, map2, map3, field, string, int, list, float)
import WebGL exposing (Mesh, Shader)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)

type alias Vector =
  { x : Float
  , y : Float
  , z : Float
  }

type alias Face =
  { v1 : Int
  , v2 : Int
  , v3 : Int
  }

type alias Triangle =
  { v1 : Vector
  , v2 : Vector
  , v3 : Vector
  }

type alias MyMesh =
  { vertices : List Vector
  , faces : List Face
  , triangles : List Triangle
  }

type alias Model =
  { mesh: MyMesh
  , currentTime : Float
  , error : String
  }

type alias Vertex =
  { position : Vec3
  , color : Vec3
  }

type Msg
  = LoadData
  | GotData ( Result Http.Error MyMesh )
  | Tick Float


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

init : () -> ( Model, Cmd Msg )
init _ = ( {mesh={vertices=[], faces=[], triangles=[]}, error="", currentTime=0}, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LoadData -> ( model, fetchDataFromBackend )

    GotData result ->
      case result of
        Ok mesh ->
          ( { model | mesh = mesh, error="" }, Cmd.none )
        
        Err error ->
          ( { model | mesh={vertices=[], faces=[], triangles=[]}, error = Debug.toString error}, Cmd.none )
    
    Tick delta ->
      ( { model | currentTime = model.currentTime + delta }
      , Cmd.none
      )

subscriptions : Model -> Sub Msg
subscriptions model =
  onAnimationFrameDelta (\delta -> Tick delta)

view : Model -> Html Msg
view model =
  div
    []
    [ div [] [text "hello from elm"]
    , div [] [button [ onClick LoadData ] [ text "Load data" ]]
    , div [] [text <| vertices_to_strings model.mesh.vertices]
    , div [] [text <| faces_to_strings model.mesh.faces]
    , div [] [text <| triangles_to_strings model.mesh.triangles]
    , div [] [text model.error]
    , WebGL.toHtml
      [ width 800
      , height 800
      , style "display" "block"
      ]
      [ WebGL.entity
          vertexShader
          fragmentShader
          (update_mesh model)
          { perspective = perspective (model.currentTime / 1000) }
      ]
    ]

perspective : Float -> Mat4
perspective t =
  Mat4.mul
    (Mat4.makePerspective 45 1 0.01 100)
    (Mat4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) (vec3 0 0 0) (vec3 0 1 0))

vertices_to_strings : List Vector -> String
vertices_to_strings vertices =
  List.map Debug.toString vertices |> String.concat

faces_to_strings : List Face -> String
faces_to_strings faces =
  List.map Debug.toString faces |> String.concat

triangles_to_strings : List Triangle -> String
triangles_to_strings triangles =
  List.map Debug.toString triangles |> String.concat

fetchDataFromBackend : Cmd Msg
fetchDataFromBackend =
  Http.get
  { url = "/api/cube"
  , expect = Http.expectJson GotData meshDecoder
  }

meshDecoder : Decoder MyMesh
meshDecoder =
  map3 MyMesh
    (field "mesh" (field "vertices" (list vectorDecoder)))
    (field "mesh" (field "faces" (list faceDecoder)))
    (field "mesh" (field "triangles" (list triangleDecoder)))

vectorDecoder : Decoder Vector
vectorDecoder =
  map3 Vector
    (field "x" float)
    (field "y" float)
    (field "z" float)

faceDecoder : Decoder Face
faceDecoder =
  map3 Face
   (field "v1" int)
   (field "v2" int)
   (field "v3" int)

triangleDecoder : Decoder Triangle
triangleDecoder =
  map3 Triangle
    (field "v1" vectorDecoder)
    (field "v2" vectorDecoder)
    (field "v3" vectorDecoder)

update_mesh : Model -> Mesh Vertex
update_mesh model =
  WebGL.triangles <| triangles_to_mesh model.mesh.triangles

triangles_to_mesh : List Triangle -> List (Vertex, Vertex, Vertex)
triangles_to_mesh triangles =
  List.map triangle_to_vertices triangles

triangle_to_vertices : Triangle -> (Vertex, Vertex, Vertex)
triangle_to_vertices triangle =
  ( Vertex (vec3 triangle.v1.x triangle.v1.y triangle.v1.z) mesh_color
  , Vertex (vec3 triangle.v2.x triangle.v2.y triangle.v2.z) mesh_color
  , Vertex (vec3 triangle.v3.x triangle.v3.y triangle.v3.z) mesh_color
  )

mesh_color : Vec3
mesh_color = vec3 0.8 0.8 0.8

type alias Uniforms =
  { perspective : Mat4 }

vertexShader : Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
  [glsl|
    attribute vec3 position;
    attribute vec3 color;
    uniform mat4 perspective;
    varying vec3 vcolor;
    void main () {
      gl_Position = perspective * vec4(position, 1.0);
      vcolor = color;
    }
  |]

fragmentShader : Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
  [glsl|
    precision mediump float;
    varying vec3 vcolor;
    void main () {
      gl_FragColor = vec4(vcolor, 1.0);
    }
  |]