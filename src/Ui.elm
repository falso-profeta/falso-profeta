module Ui exposing (..)

-- import Css exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy)
import Json.Encode
import Types exposing (..)



--- LAYOUT ELEMENTS ------------------------------------------------------------


appShell : Url -> Html msg -> Quote -> Html msg -> Html msg
appShell url navLink quote child =
    let
        contentDiv =
            div [ class "MainContent" ] [ child ]
    in
    div
        [ class "App", style "background-image" (asUrl url) ]
        [ viewQuote quote, contentDiv, navLink ]


navLinks : msg -> Html msg
navLinks msg =
    div [ class "InitLink" ]
        [ a
            [ href "#", onClick msg ]
            [ i [ class "fas fa-chevron-left" ] [], text " início" ]
        ]


emptyNav : Html msg
emptyNav =
    text ""


asUrl st =
    "url(\"" ++ st ++ "\")"



--- PAGE ITEMS -----------------------------------------------------------------


youtubeIframe : String -> Url -> Html msg
youtubeIframe cls url =
    let
        normalizedUrl =
            url

        -- String.replace "watch?" "embed?" url
    in
    iframe
        [ width 500
        , height 375
        , attribute "max-width" "100%"
        , class cls
        , src normalizedUrl
        , property "title" (Json.Encode.string "Youtube")
        , property "frameborder" (Json.Encode.string "0")
        , property "allowfullscreen" (Json.Encode.string "true")
        , property "allow" (Json.Encode.string "accelerometer; autoplay; encrypted-media; clipboard-write; gyroscope; picture-in-picture")
        , attribute "allowfullscreen" "true"
        ]
        []



--- ATOMIC ELEMENTS ------------------------------------------------------------


highlight : List (Html msg) -> Html msg
highlight children =
    span [] children


icon : String -> Html msg
icon which =
    i [ class which ] []


fab : msg -> String -> Html msg
fab msg cls =
    button [ onClick msg, class "FabButton" ] [ icon cls ]


fabText : msg -> String -> Html msg
fabText msg txt =
    button
        [ onClick msg, class "FabButton", style "border-radius" "20px", style "padding" "0 0.5em", style "width" "inherit" ]
        [ span [ style "font-size" "70%", style "padding" "0.5em" ] [ text txt ] ]
