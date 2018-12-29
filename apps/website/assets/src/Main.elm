module Main exposing (main)

import Browser
import Browser.Dom exposing (getViewport)
import Browser.Events exposing (onResize)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (style, class)
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
  , mouseXPos : Float
  , mouseYPos : Float
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
  , mouseXPos = 1
  , mouseYPos = 1
  }
  , Task.perform (\{ viewport } -> Resize viewport.width viewport.height) getViewport
  )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MouseMoved event ->
      ( { model
          | text = Debug.toString event
          , mouseXPos = Tuple.first event.pagePos
          , mouseYPos = Tuple.second event.pagePos
        }
      , Cmd.none
      )

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
    [ style
        "background-color"
        (
        "rgb("
          ++ (Debug.toString (model.mouseXPos / model.screenWidth * 255.0))
          ++ ", 255, "
          ++ (Debug.toString (model.mouseYPos / model.screenHeight * 255.0))
        )
    , style "widht" (Debug.toString model.screenWidth ++ "px")
    , style "height" (Debug.toString model.screenHeight ++ "px")
    , style "text-align" "center"
    , Mouse.onMove MouseMoved
    ]
    [
      button
        [ class "myButton center" ]
        [ text "Fullscreen" ]
      , div [] [ text (Debug.toString model.text) ]
    ]


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }