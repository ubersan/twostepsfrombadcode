module WebGLPage exposing (main)

import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Html exposing (Html)
import Html.Attributes exposing (width, height, style)
import WebGL exposing (Mesh, Shader)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (vec3, Vec3)

type alias Model =
  { currentTime : Float }

type Msg = Tick Float

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , subscriptions = subscriptions
    , update = update
    }

init : () -> ( Model, Cmd Msg )
init _ =
  ( { currentTime = 0 }
  , Cmd.none
  )

subscriptions : Model -> Sub Msg
subscriptions model =
  onAnimationFrameDelta (\delta -> Tick delta)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Tick delta ->
      ( { model | currentTime = model.currentTime + delta }
      , Cmd.none
      )

view : Model -> Html Msg
view model =
  WebGL.toHtml
    [ width 400
    , height 400
    , style "display" "block"
    ]
    [ WebGL.entity
      vertexShader
      fragmentShader
      mesh
      { perspective = perspective (model.currentTime / 1000) }
    ]

perspective : Float -> Mat4
perspective t =
  Mat4.mul
    (Mat4.makePerspective 45 1 0.01 100)
    (Mat4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) (vec3 0 0 0) (vec3 0 1 0))

type alias Vertex =
  { position : Vec3
  , color : Vec3
  }

mesh : Mesh Vertex
mesh =
  WebGL.triangles
    [ ( Vertex (vec3 0 0 0) (vec3 1 0 0)
    , Vertex (vec3 1 1 0) (vec3 0 1 0)
    , Vertex (vec3 1 -1 0) (vec3 0 0 1)
    )
    ]

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