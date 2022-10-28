module Pages.Intro exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Ev
import Types exposing (Quote(..))
import Ui


view : msg -> Html msg
view nextMsg =
    let
        quote =
            Quote
                """
            E surgirão muitos falsos profetas e enganarão muitos. 
            E, por se multiplicar a iniquidade, o amor de muitos se esfriará.
            """
                "Mateus 24:11-12"

        content =
            div [ class "ContentBox delay" ]
                [ h1 []
                    [ text "A política é cheia de falsos profetas." ]
                , p []
                    [ strong [] [ text "Bolsonaro" ]
                    , text " se diz cristão, mas será que ele é um deles? Vamos julgar pelas suas ações."
                    ]
                , a
                    [ href "#", Ev.onClick nextMsg ]
                    [ text "continue..." ]
                , div [ class "ContentBox-controls" ] [ Ui.fab nextMsg "fas fa-chevron-right" ]
                ]
    in
    Ui.appShell "./static/cruz.jpg" Ui.emptyNav quote content
