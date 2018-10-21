module Ui exposing
    ( appWrapper
    , banner
    , fab
    , icon
    , mainQuote
    , quoteLayout
    , styleElements
    , youtubeIframe
    )

-- import Css exposing (..)

import Bootstrap.Button as Btn
import Bootstrap.CDN as CDN
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy)
import Json.Decode
import Json.Encode
import Model exposing (..)
import Style exposing (..)
import Update exposing (Msg(..))



--- LAYOUT ELEMENTS ------------------------------------------------------------


appWrapper : List (Html msg) -> Html msg
appWrapper child =
    div [ class "AppWrapper" ] child


quoteLayout : String -> Url -> Quote -> Html Msg -> Html Msg
quoteLayout elemId url quote child =
    div
        [ class "Quote", id elemId ]
        [ div [ class "Nav" ]
            [ i [ onClick Prev, class "fas fa-arrow-left" ] []
            , i [ onClick Next, class "fas fa-arrow-right" ] []
            ]
        , div
            [ class "Quote-background"
            , style "background-image" (asUrl url)
            ]
            []
        , div
            [ class "Quote-overlay" ]
            [ lazy quotation quote
            , div [ class "Quote-content" ] [ child ]
            ]
        ]


asUrl st =
    "url(\"" ++ st ++ "\")"


quotation : Quote -> Html msg
quotation (Quote quote from) =
    div [ class "Quotation" ]
        [ blockquote []
            [ span [] [ text quote ] ]
        , Html.cite [] [ text from ]
        ]


banner : Url -> Quote -> Html msg
banner imgUrl (Quote quote from) =
    div
        [ class "Banner" ]
        [ blockquote
            []
            [ highlight [ text quote ] ]
        , div
            []
            [ highlight [ text ("- " ++ from) ] ]
        ]



--- PAGE ITEMS -----------------------------------------------------------------


mainQuote : Quote -> Html msg
mainQuote quote =
    div [] []


youtubeIframe : String -> Url -> Html msg
youtubeIframe cls url =
    iframe
        [ width 500
        , height 375
        , class cls
        , src url
        , property "frameborder" (Json.Encode.string "0")
        , property "allowfullscreen" (Json.Encode.string "true")
        , property "allow" (Json.Encode.string "autoplay; encrypted-media")
        , attribute "allowfullscreen" "true"
        ]
        []



--- ATOMIC ELEMENTS ------------------------------------------------------------


highlight : List (Html msg) -> Html msg
highlight children =
    span
        [-- css
         -- [ backgroundColor (hex "fff")
         -- , padding2 (Css.em 0.05) (Css.em 0.5)
         -- ]
        ]
        children


icon : String -> Html msg
icon which =
    i [ class which ] []


fab : msg -> String -> Html msg
fab msg cls =
    button [ onClick msg, class "Fab" ] [ icon cls ]



--- RESOURCES -----------------------------------------------------------------


styleSheet : Url -> Html msg
styleSheet url =
    node "link"
        [ attribute "rel" "stylesheet"
        , href url
        ]
        []


styleElements : List (Html msg)
styleElements =
    [ styleSheet "https://fonts.googleapis.com/css?family=Anton|Quicksand|Roboto+Slab|Material+Icons|Roboto+Mono"
    , styleSheet "https://use.fontawesome.com/releases/v5.4.1/css/all.css"
    , styleSheet "https://cdnjs.cloudflare.com/ajax/libs/normalize/8.0.0/normalize.css"
    , styleSheet "/static/main.css"
    ]
