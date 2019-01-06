module Home exposing (main)

import Browser

import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Http
import Json.Decode exposing (Decoder, map, map2, map3, field, string, int, list, float)

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

type alias Mesh =
  { vertices : List Vector
  , faces : List Face
  }

type alias Model =
  { mesh: Mesh
  , error : String
  }

type Msg
  = LoadData
  | GotData ( Result Http.Error Mesh )


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

init : () -> ( Model, Cmd Msg )
init _ = ( {mesh={vertices=[], faces=[]}, error=""}, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LoadData -> ( model, fetchDataFromBackend )

    GotData result ->
      case result of
        Ok mesh ->
          ( { model | mesh = mesh, error="" }, Cmd.none )
        
        Err error ->
          ( { model | mesh={vertices=[], faces=[]}, error = Debug.toString error}, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model =
  div
    []
    [ div [] [text "hello from elm"]
    , div [] [button [ onClick LoadData ] [ text "Load data" ]]
    , div [] [text <| vertices_to_strings model.mesh.vertices]
    , div [] [text <| faces_to_strings model.mesh.faces]
    , div [] [text model.error]
    ]

vertices_to_strings : List Vector -> String
vertices_to_strings vertices =
  List.map Debug.toString vertices |> String.concat

faces_to_strings : List Face -> String
faces_to_strings faces =
  List.map Debug.toString faces |> String.concat

fetchDataFromBackend : Cmd Msg
fetchDataFromBackend =
  Http.get
  { url = "/api/cube"
  , expect = Http.expectJson GotData meshDecoder
  }

meshDecoder : Decoder Mesh
meshDecoder =
  map2 Mesh
    (field "mesh" (field "vertices" (list vectorDecoder)))
    (field "mesh" (field "faces" (list faceDecoder)))

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