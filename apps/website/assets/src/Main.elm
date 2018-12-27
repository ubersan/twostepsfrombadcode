module Main exposing (main)

import Browser

import Html exposing (Html, div, text)
import Html.Events exposing (onClick)

type alias Color =
  { r: Int
  , g: Int
  , b: Int
  }

type alias Model = Color

type Msg =
  MouseClicked


init : () -> (Model, Cmd Msg)
init _ =
  ({r=100, b=100, g=100}
  , Cmd.none
  )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MouseClicked ->
      ( model, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

view : Model -> Html Msg
view model =
  div [] [text "Hello from elm"]

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }