module Main exposing (main)

import Browser
import Browser.Dom exposing (getViewport)
import Browser.Events exposing (onResize)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (style)
import Html.Events.Extra.Mouse as Mouse

import Task

type alias Color =
  { r: Int
  , g: Int
  , b: Int
  }

type alias Model = 
  { color: Color
  , text: String
  , screenWidth : Float
  , screenHeight : Float
  }

type Msg
  = MouseMoved Mouse.Event
  | Resize Float Float


init : () -> (Model, Cmd Msg)
init _ =
  ({ color={r=100, b=100, g=100}
  , text="test text"
  , screenWidth = 1
  , screenHeight = 1
  }
  , Task.perform (\{ viewport } -> Resize viewport.width viewport.height) getViewport
  )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MouseMoved event ->
      ( { model | text = Debug.toString event }, Cmd.none )

    Resize width height ->
      ( { model
          | screenWidth = width
          , screenHeight = height
        }
      , Cmd.none
      )

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.none
    , onResize (\w h -> Resize (toFloat w) (toFloat h))
    ]

view : Model -> Html Msg
view model =
  div
    [ style "background-color" "red"
    , Mouse.onMove MouseMoved
    ]
    [ div [] [ text model.text ]
    , div [] [ text <| Debug.toString model.screenWidth ]
    , div [] [ text <| Debug.toString model.screenHeight ]
    ]

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }