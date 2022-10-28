module Types exposing (Quote(..), Transition(..), Url, transitionDuration, viewQuote)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import String


type alias Url =
    String


type Quote
    = Quote String String


type Transition
    = FadeOut
    | FromLeft
    | FromRight
    | NoTransition
    | Reset


viewQuote : Quote -> Html msg
viewQuote (Quote st from) =
    let
        clean =
            String.join " " <| String.words st

        n =
            String.length clean

        attrs =
            if n > 200 then
                [ style "font-size" "0.85em" ]

            else if n > 150 then
                [ style "font-size" "0.95em" ]

            else if n > 125 then
                [ style "font-size" "1.05em" ]

            else
                []
    in
    div [ class "Quote" ]
        [ blockquote attrs [ span [] [ text st ] ]
        , Html.cite [] [ text from ]
        ]


transitionDuration : Transition -> Float
transitionDuration step =
    case step of
        FadeOut ->
            150

        Reset ->
            1

        NoTransition ->
            0

        FromLeft ->
            250

        FromRight ->
            250
