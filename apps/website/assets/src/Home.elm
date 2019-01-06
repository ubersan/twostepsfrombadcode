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

type alias Mesh =
  { coords : List Vector
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
init _ = ( {mesh={coords=[]}, error=""}, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LoadData -> ( model, fetchDataFromBackend )

    GotData result ->
      case result of
        Ok mesh ->
          ( { model | mesh = mesh, error="" }, Cmd.none )
        
        Err error ->
          ( { model | mesh={coords=[{x=-1,y=-1,z=-1}]}, error = Debug.toString error}, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model =
  div
    []
    [ div [] [text "hello from elm"]
    , div [] [button [ onClick LoadData ] [ text "Load data" ]]
    , div [] [text <| coords_to_strings model.mesh.coords]
    , div [] [text model.error]
    ]

coords_to_strings : List Vector -> String
coords_to_strings coords =
  List.map Debug.toString coords |> String.concat

fetchDataFromBackend : Cmd Msg
fetchDataFromBackend =
  Http.get
  { url = "/api/cube"
  , expect = Http.expectJson GotData meshDecoder
  }

meshDecoder : Decoder Mesh
meshDecoder =
  map Mesh (field "cube" (field "vertices" (list vectorDecoder)))

vectorDecoder : Decoder Vector
vectorDecoder =
  map3 Vector
    (field "x" float)
    (field "y" float)
    (field "z" float)