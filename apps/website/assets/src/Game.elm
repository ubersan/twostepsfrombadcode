module Game exposing (main)

import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Html exposing (Html, div)
import Html.Attributes exposing (width, height, style)
import WebGL exposing (Mesh, Shader)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

type Msg
  = Clicked

type alias Model =
  { mouseX : Int
  , mouseY : Int
  }

init : () -> (Model, Cmd Msg)
init _ = ( {mouseX=0, mouseY=0}, Cmd.none )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of

    Clicked ->
      ( model, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model =
  div
    []
    [ WebGL.toHtml
        [ width 1000
        , height 1000
        , style "display" "block"
        , style "background-color" "blue"
        ]
        [ WebGL.entity
            vertexShader
            fragmentShader
            mesh
            uniforms
        ]
    ]

type alias Uniforms =
  { perspective : Mat4
  , camera : Mat4
  }

mesh : Mesh Vertex
mesh =
  WebGL.triangles
    [(Vertex (vec3 0 0 0) mesh_color (vec3 0 0 1)
    , Vertex (vec3 0 1 0) mesh_color (vec3 0 0 1)
    , Vertex (vec3 1 0 0) mesh_color (vec3 0 0 1)
    )]

mesh_color : Vec3
mesh_color = vec3 1 1 1

uniforms : Uniforms
uniforms =
  { perspective = Mat4.makePerspective 90 1 0.01 100
  , camera = Mat4.makeLookAt (vec3 1 1 1) (vec3 1 1 0) (vec3 0 1 0)
  }

type alias Vertex =
  { position : Vec3
  , color : Vec3
  , normal : Vec3
  }

vertexShader : Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
  [glsl|
    attribute vec3 position;
    attribute vec3 normal;
    attribute vec3 color;
    uniform mat4 perspective;
    uniform mat4 camera;
    varying vec3 vcolor;
    void main () {
      gl_Position = perspective * camera * vec4(position, 1.0);
      
      vec3 light_dir = normalize(vec3(0, 0, -1));
      vcolor = max(dot((vec4(normal, 1.0)).xyz, -light_dir), 0.0) * color;
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