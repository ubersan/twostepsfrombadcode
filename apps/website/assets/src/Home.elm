module Home exposing (main)

import Browser

import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Http
import Json.Decode exposing (Decoder, map2, field, string, int)

type alias User =
  { id : Int
  , name : String
  }

type alias Model =
  { user: User }

type Msg
  = LoadData
  | GotData ( Result Http.Error User )


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

init : () -> ( Model, Cmd Msg )
init _ = ( {user={id=0, name="default"}}, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LoadData -> ( model, fetchDataFromBackend )

    GotData result ->
      case result of
        Ok user ->
          ( { model | user = user }, Cmd.none )
        
        Err error ->
          ( { model | user={name=Debug.toString error, id=-1 } }, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model =
  div
    []
    [ div [] [text "hello from elm"]
    , div [] [button [ onClick LoadData ] [ text "Load data" ]]
    , div [] [text <| String.fromInt model.user.id]
    , div [] [text model.user.name]
    ]

fetchDataFromBackend : Cmd Msg
fetchDataFromBackend =
  Http.get
  { url = "/api/cube"
  , expect = Http.expectJson GotData jsonDecoder
  }

jsonDecoder : Decoder User
jsonDecoder =
  field "user" (map2 User (field "id" int) (field "name" string))