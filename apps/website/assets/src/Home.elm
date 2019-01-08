module Home exposing (main)

import Browser
import Browser.Events exposing (onAnimationFrameDelta)

import Html exposing (Html, div, text, button, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (style, width, height, type_, min, max, step, value)
import Http
import Json.Decode exposing (Decoder, map, map2, map3, map6, field, string, int, list, float)
import WebGL exposing (Mesh, Shader)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)

type alias Vector =
  { x : Float
  , y : Float
  , z : Float
  , nx : Float
  , ny : Float
  , nz : Float
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
  { triangles : List Triangle
  }

type alias Model =
  { mesh: MyMesh
  , currentTime : Float
  , rotation_speed : Float
  , error : String
  }

type alias Vertex =
  { position : Vec3
  , color : Vec3
  , normal : Vec3
  }

type Msg
  = LoadData
  | GotData ( Result Http.Error MyMesh )
  | Tick Float
  | RotationSpeedChange String


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

init : () -> ( Model, Cmd Msg )
init _ = ( {mesh={triangles=[]}, error="", currentTime=0, rotation_speed=0.5}, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LoadData -> ( model, fetchDataFromBackend )

    GotData result ->
      case result of
        Ok mesh ->
          ( { model | mesh = mesh, error="" }, Cmd.none )
        
        Err error ->
          ( { model | mesh={triangles=[]}, error = Debug.toString error}, Cmd.none )
    
    Tick delta ->
      ( { model | currentTime = model.currentTime + (delta / 5000 * model.rotation_speed) }
      , Cmd.none
      )

    RotationSpeedChange rotation_speed ->
      ( { model | rotation_speed =
            case String.toFloat rotation_speed of
              Just f -> f
              Nothing -> 0.5
        }
      , Cmd.none
      )

subscriptions : Model -> Sub Msg
subscriptions model =
  onAnimationFrameDelta (\delta -> Tick delta)

view : Model -> Html Msg
view model =
  div
    []
    [ div [] [ button [ onClick LoadData ] [ text "Load data" ] ]
    , div
      []
      [ text "Rotation speed"
      , input [ type_ "range", min "0", max "1", step "0.01", value (String.fromFloat model.rotation_speed), onInput RotationSpeedChange ] [ text "Slider" ]
      ]
    , div [] [ text <| String.fromFloat model.rotation_speed ]
    , div [] [ text model.error ]
    , WebGL.toHtml
      [ width 800
      , height 800
      , style "display" "block"
      ]
      [ WebGL.entity
          vertexShader
          fragmentShader
          (update_mesh model)
          (uniforms model.currentTime)
      ]
    ]

uniforms : Float -> Uniforms
uniforms currentTime =
  { rotation =
      Mat4.mul
        (Mat4.makeRotate (3 * currentTime ) (vec3 0 1 0))
        (Mat4.makeRotate (2 * currentTime) (vec3 1 0 0))
  , perspective = Mat4.makePerspective 45 1 0.01 100
  , camera = Mat4.makeLookAt (vec3 0 0 5) (vec3 0 0 0) (vec3 0 1 0)
  }

fetchDataFromBackend : Cmd Msg
fetchDataFromBackend =
  Http.get
  { url = "/api/mesh/cube"
  , expect = Http.expectJson GotData meshDecoder
  }

meshDecoder : Decoder MyMesh
meshDecoder =
  map MyMesh (field "mesh" (field "triangles" (list triangleDecoder)))

vectorDecoder : Decoder Vector
vectorDecoder =
  map6 Vector
    (field "x" float)
    (field "y" float)
    (field "z" float)
    (field "nx" float)
    (field "ny" float)
    (field "nz" float)

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
  ( Vertex (vec3 triangle.v1.x triangle.v1.y triangle.v1.z) mesh_color (vec3 triangle.v1.nx triangle.v1.ny triangle.v1.nz)
  , Vertex (vec3 triangle.v2.x triangle.v2.y triangle.v2.z) mesh_color (vec3 triangle.v2.nx triangle.v2.ny triangle.v2.nz)
  , Vertex (vec3 triangle.v3.x triangle.v3.y triangle.v3.z) mesh_color (vec3 triangle.v3.nx triangle.v3.ny triangle.v3.nz)
  )

mesh_color : Vec3
mesh_color = vec3 0.8 0.8 0.8

type alias Uniforms =
  { rotation : Mat4
  , perspective : Mat4
  , camera : Mat4
  }

vertexShader : Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
  [glsl|
    attribute vec3 position;
    attribute vec3 normal;
    attribute vec3 color;
    uniform mat4 perspective;
    uniform mat4 camera;
    uniform mat4 rotation;
    varying vec3 vcolor;
    void main () {
      gl_Position = perspective * camera * rotation * vec4(position, 1.0);
      
      vec3 light_dir = normalize(vec3(1, 0.0, 0.0));
      vcolor = max(dot((rotation * vec4(normal, 1.0)).xyz, light_dir), 0.0) * color;
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